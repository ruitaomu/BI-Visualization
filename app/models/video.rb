class Video < ActiveRecord::Base
  belongs_to :tester
  belongs_to :project
  has_many :tags, dependent: :destroy

  accepts_nested_attributes_for :tags, allow_destroy: true

  validates :tester, :project, presence: true

  def tags_for_chart
    tags.map do |tag|
      [ tag.name, tag.id.to_s, tag.starts, tag.ends ]
    end
  end
end
