class Video < ActiveRecord::Base
  belongs_to :tester
  belongs_to :project
  has_many :tags, dependent: :destroy
  has_many :datafiles, dependent: :destroy

  accepts_nested_attributes_for :tags,
                                allow_destroy: true,
                                reject_if: proc { |attrs| attrs['name'].blank? }

  accepts_nested_attributes_for :datafiles,
                                allow_destroy: true

  validates :tester, :project, presence: true

  def tags_for_chart
    tags.order('tags.group').map do |tag|
      [ tag.name, tag.group, tag.id.to_s, tag.starts, tag.ends ]
    end
  end
end
