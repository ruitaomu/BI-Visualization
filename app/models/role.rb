class Role < ActiveRecord::Base
  has_and_belongs_to_many :users

  RESOURCES = %w(User Role Video)

  validates :name, presence: true

  def readonly?
    admin?
  end

private
  def admin?
    name == 'admin'
  end
end
