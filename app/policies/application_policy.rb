class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def permitted_params
    @_permitted_params ||= (user.admin? ? @record.class.attribute_names.map(&:to_sym) : [])
  end

  def permitted_param?(param)
    permitted_params.include?(param.to_sym)
  end

  def visible_attributes
    return @_visible_attributes unless @_visible_attributes.nil?
    klass = @record.respond_to?(:attribute_names) ? @record : @record.class
    @_visible_attributes = user.admin? ? klass.attribute_names.map(&:to_sym) : []
  end

  def visible_attribute?(attribute)
    return true unless attribute.is_a?(Symbol)
    visible_attributes.include?(attribute)
  end

  def index?
    user.admin?
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def create?
    user.admin?
  end

  def new?
    create?
  end

  def update?
    user.admin?
  end

  def edit?
    update?
  end

  def destroy?
    user.admin?
  end

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
end

