class Project < ActiveRecord::Base
  belongs_to :customer
  has_many :testers

  validates :name, :customer_id, presence: true

  def to_s
    name
  end
end
