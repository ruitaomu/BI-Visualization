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

    self.update_attributes(metadata: { title: title, columns: columns, rows: datarows})
  end

  def parse_datafile(file_path)
    file = open(file_path)
    workbook = RubyXL::Parser.parse(file.path)
    worksheet = workbook[0]
    datarows = worksheet.extract_data
  end

  def rows_for_chart
    deviation = self.get_standard_deviation * self.threshold
    dataRows = self.metadata['rows']
    rows = dataRows.first.each_with_index.map do |row, index|
      [ dataRows[2][index], dataRows[1][index], dataRows[0][index, self.moving_average].simple_moving_average, deviation, -deviation ]
    end
    rows
  end

  def get_standard_deviation
    dataRows = self.metadata['rows']
    data = []
    dataRows.first.each_with_index.map do |row, index|
      data << dataRows[0][index, self.moving_average].simple_moving_average
    end
    data.standard_deviation
  end


end
