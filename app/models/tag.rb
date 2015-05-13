class Tag < ActiveRecord::Base
  belongs_to :video

  def self.names(video)
    video.tags.pluck(:name).uniq
  end

  def self.groups
    distinct.pluck(:group).compact.reject(&:empty?)
  end

  def to_s
    name
  end

  def duration
    ((((self.ends.to_f / 1000) - (self.starts.to_f / 1000)) / 60) % 60).round(3)
  end
end
