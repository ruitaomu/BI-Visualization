class ApplicationPolicy
  attr_reader :user, :record

  def self.get(user, subject)
    Pundit.policy(user, subject) ||
    ApplicationPolicy.new(user, subject)
  end

  def initialize(user, record)
    @user = user || User.guest
    @record = record
  end

  def permitted_params
    return @_permitted_params unless @_permitted_params.nil?
    klass = @record.respond_to?(:attribute_names) ? @record : @record.class
    @_permitted_params ||= (user.is_admin? ? klass.attribute_names.map(&:to_sym) : [])
  end

  def permitted_param?(param)
    permitted_params.include?(param.to_sym)
  end

  def visible_attributes
    return @_visible_attributes unless @_visible_attributes.nil?
    klass = @record.respond_to?(:attribute_names) ? @record : @record.class
    @_visible_attributes = user.is_admin? ? klass.attribute_names.map(&:to_sym) : []
  end

  def visible_attribute?(attribute)
    return true unless attribute.is_a?(Symbol)
    visible_attributes.include?(attribute)
  end

  def index?
    user.permitted_to?(:read, record_class)
  end

  def show?
    user.permitted_to?(:show, record_class)
  end

  def create?
    user.permitted_to?(:create, record_class)
  end
  alias_method :new?, :create?

  def update?
    user.permitted_to?(:update, record_class)
  end
  alias_method :edit?, :update?

  def destroy?
    user.permitted_to?(:destroy, record_class)
  end
  alias_method :delete?, :destroy?

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

private
  def record_class
    record.class == Class ? record : record.class
  end
end
