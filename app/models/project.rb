class Project < ActiveRecord::Base
  self.inheritance_column = false
  belongs_to :customer
  has_many :videos
  has_many :testers, through: :videos

  validates :name, :customer_id, presence: true

  attr_accessor :tester_id

  def tester_id=(id)
    self.testers << Tester.find(id)
  end

  def self.project_types
      distinct.pluck(:type).compact.reject(&:empty?)
  end

  def to_s
    name
  end
end
