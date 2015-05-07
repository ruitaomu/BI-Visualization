class Datafile < ActiveRecord::Base
  belongs_to :video
  validates :video_id, presence: true

  def update_metadata(file_path)
    datarows = parse_datafile(file_path)
    title, columns = [], []

    datarows.each_with_index do |row, index|
       title << row.shift(3).join(' ')
       columns << row.shift(1).join(' ')
    end

    rows = datarows.first.each_with_index.map do |value, index|
      [ datarows[2][index], datarows[1][index], datarows[0][index, self.moving_average].simple_moving_average ]
    end

    self.update_attributes(metadata: { title: title, columns: columns, rows: rows})
  end

  def parse_datafile(file_path)
    file = open(file_path)
    workbook = RubyXL::Parser.parse(file.path)
    worksheet = workbook[0]
    datarows = worksheet.extract_data
  end
end
