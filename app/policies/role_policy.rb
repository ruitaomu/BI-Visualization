class RolePolicy < ApplicationPolicy
  def permitted_params
    super + [{ permissions_attributes: [ :resource, actions: [] ] }]
  end

  def update?
    !admin_role? && super
  end

  def destroy?
    !admin_role? && super
  end

private
  def admin_role?
    record.is_a?(Role) && record.admin?
  end
end
