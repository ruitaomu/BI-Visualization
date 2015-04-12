class Tester < ActiveRecord::Base
  has_many :videos
  has_many :projects, through: :videos

  validates :name, presence: true

  def to_s
    name
  end
end
