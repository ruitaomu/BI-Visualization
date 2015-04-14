class Tag < ActiveRecord::Base
  belongs_to :video

  def self.names(video)
    video.tags.pluck(:name).uniq
  end

  def to_s
    name
  end
end
