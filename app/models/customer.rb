class Customer < ActiveRecord::Base
  has_many :projects, dependent: :destroy

  def to_s
    name
  end
end
