class Video < ActiveRecord::Base
  belongs_to :tester
  belongs_to :project
  has_many :tags, dependent: :destroy
  has_one :tag_series, dependent: :destroy
  has_many :datafiles, dependent: :destroy

  accepts_nested_attributes_for :tags,
                                allow_destroy: true,
                                reject_if: proc { |attrs| attrs['name'].blank? }

  accepts_nested_attributes_for :datafiles,
                                allow_destroy: true

  validates :tester, :project, presence: true

  def tags_for_chart
    chart_tags  = tags.normal.order('tags.group').map do |tag|
      [ tag.hierarchy, tag.parent_tag.present? ? tag.parent_tag.id.to_s : '' , tag.group, tag.id.to_s, tag.starts, tag.ends ]
    end
  end

  def auto_tags_for_chart
    chart_tags  = tags.automatic.order('tags.group').map do |tag|
      [ tag.name, tag.group, tag.id.to_s, tag.starts, tag.ends ]
    end
    missing_tags = ['Above Std Dev', 'Below Std Dev', 'Above Average', 'Below Average'] - tags.automatic.collect(&:name).uniq
    missing_tags.each do |name|
      chart_tags << [ name, '', '0', 0, 0 ]
    end
    chart_tags
  end

  def tag_series_for_chart
    tag_ids = self.tag_series.try(:tag_ids).map(&:to_i)
    chart_tags  = tags.normal.where('id IN (?)', tag_ids).map do |tag|
      [ tag.hierarchy, tag.group, tag.id.to_s, tag.starts, tag.ends ]
    end
  end
end
