class Tag < ActiveRecord::Base
  belongs_to :video
  has_many :child_tags, :class_name => "Tag", foreign_key: :parent_id, inverse_of: :parent_tag, dependent: :destroy
  belongs_to :parent_tag, :class_name => "Tag", foreign_key: :parent_id, inverse_of: :child_tags
  scope :automatic, -> {where(auto: true)}
  scope :normal, -> {where(auto: false)}

  def self.names(video)
    video.tags.normal.pluck(:name).uniq
  end

  def self.orphans(video)
    video.tags.normal.where(parent_id: nil).uniq
  end

  def self.groups
    distinct.normal.pluck(:group).compact.reject(&:empty?)
  end

  def to_s
    name
  end

  def duration_in_secs
    ((self.ends.to_f / 1000) - (self.starts.to_f / 1000)).round(3)
  end

  def hierarchy
    parent_tag.present? ? parent_tag.name + " > " + name : name
  end
end
