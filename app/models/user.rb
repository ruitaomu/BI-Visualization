class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_and_belongs_to_many :roles

  def self.guest
    new
  end

  def has_role?(name)
    roles.where(name: name).exists?
  end

  # Special omnipotent role
  def is_admin?
    has_role?(:admin)
  end

  def permitted_to?(action, resource)
    return true if is_admin?
    # No need for a scope query as there won't be that many roles on the DB
    roles.pluck(:permissions).detect do |permission|
      (permission[resource] || []).include?(action.to_s)
    end
  end
end
