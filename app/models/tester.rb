class Tester < ActiveRecord::Base
  belongs_to :project

  validates :name, presence: true

  def to_s
    name
  end
end
