class Role < ActiveRecord::Base
  has_many :permissions
  has_and_belongs_to_many :users

  accepts_nested_attributes_for :permissions, allow_destroy: true

  RESOURCES = %w(User Role Video Customer Project Tester)
  ACTIONS = %w(create read update destroy)

  validates :name, presence: true

  def permissions
    @_permissions ||= build_permissions_from_attribute
  end

  def permissions_attributes=(attributes)
    self[:permissions] = {}
    attributes.values.each do |permission|
      actions = ACTIONS & permission[:actions]
      next if actions.empty? || !RESOURCES.include?(permission['resource'])
      self[:permissions][permission[:resource]] = permission[:actions].reject(&:blank?)
    end
    @_permissions = build_permissions_from_attribute
  end

  def readonly?
    admin?
  end

  def admin?
    name == 'admin'
  end

  def to_s
    name.to_s.capitalize
  end

  class Permission
    include ActiveModel::Model
    attr_accessor :resource, :actions, :new_record

    def new_record?
      new_record != false
    end
  end

private
  def build_permissions_from_attribute
    self[:permissions].map do |resource, actions|
      Permission.new(resource: resource, actions: actions, new_record: false)
    end
  end
end
