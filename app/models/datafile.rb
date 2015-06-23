class Datafile < ActiveRecord::Base
  belongs_to :video
  validates :video_id, presence: true

  after_update :create_auto_tags
  TIME_PERIOD = 2

  def update_metadata(file_path)
    datarows = parse_datafile(file_path)
    title, columns = [], []

    datarows.each_with_index do |row, index|
       title << row.shift(3).join(' ')
       columns << row.shift(1).join(' ')
    end

    self.update_attributes(metadata: { title: title, columns: columns, rows: datarows}, data_type: columns.include?('Emo.I') ? 'emo_i':'')
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
    dataRows[1].standard_deviation
  end


  def create_auto_tags
    return if self.data_type != 'emo_i'
    self.video.tags.automatic.delete_all

    dataRows = self.metadata['rows']
    stdev = self.get_standard_deviation * self.threshold

    movingAverageAutotags = {startTime: nil, endTime: nil, state: ''}
    stdevAutotags = {startTime: nil, endTime: nil, state: ''}

    dataRows.first.each_with_index.map do |row, index|
      mvA = dataRows[0][index, self.moving_average].simple_moving_average
      value = dataRows[1][index]
      # Create above upper bound and below lower bound tags
      if (value > stdev || value < -stdev) && stdevAutotags[:startTime].nil?
        stdevAutotags[:startTime] = dataRows[2][index]
        stdevAutotags[:state] = value > stdev ? 'above' : 'below'
      elsif ((value <= stdev && stdevAutotags[:state] == 'above') || (value >= -stdev && stdevAutotags[:state] == 'below') || dataRows[2].length - 1 == index) && !stdevAutotags[:startTime].nil?
        stdevAutotags[:endTime] = dataRows[2][index-1]
      end

      if stdevAutotags[:startTime].present? && stdevAutotags[:endTime].present?
        duration = stdevAutotags[:endTime] - stdevAutotags[:startTime]
        Tag.create(name: "#{stdevAutotags[:state].humanize} Std Dev", group: '', starts: stdevAutotags[:startTime]*1000, ends: stdevAutotags[:endTime]*1000, auto: true, video_id: self.video_id) if duration > TIME_PERIOD
        stdevAutotags = {startTime: nil, endTime: nil, state: ''}
      end

      # Create above average and below average tags
      if (value > mvA || value < mvA) && movingAverageAutotags[:startTime].nil?
        movingAverageAutotags[:startTime] = dataRows[2][index]
        movingAverageAutotags[:state] = value > mvA ? 'above' : 'below'
      elsif ((value <= mvA && movingAverageAutotags[:state] =='above') || (value >= mvA && movingAverageAutotags[:state] == 'below')||  dataRows[2].length - 1 == index) && !movingAverageAutotags[:startTime].nil?
        movingAverageAutotags[:endTime] = dataRows[2][index - 1]
      end

      if movingAverageAutotags[:startTime].present? && movingAverageAutotags[:endTime].present?
        duration = movingAverageAutotags[:endTime] - movingAverageAutotags[:startTime]
        Tag.create(name: "#{movingAverageAutotags[:state].humanize} Average", group: '', starts: movingAverageAutotags[:startTime]*1000, ends: movingAverageAutotags[:endTime]*1000, auto: true, video_id: self.video_id) if duration > TIME_PERIOD
        movingAverageAutotags = {startTime: nil, endTime: nil, state: ''}
      end

    end
  end
end