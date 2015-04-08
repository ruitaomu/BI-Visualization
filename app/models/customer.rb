class Customer < ActiveRecord::Base
  has_many :projects, dependent: :destroy

  validates :name, presence: true

  def to_s
    name
  end
end
