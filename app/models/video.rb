class Video < ActiveRecord::Base
  belongs_to :tester
  belongs_to :project

  validates :tester, :project, presence: true
end
