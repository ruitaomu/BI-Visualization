class UserPolicy < ApplicationPolicy
  def permitted_params
    params = %i(email password password_confirmation)
    return super + params if user.is_admin?
    return [] unless record.id == user.id
    params
  end

  def visible_attributes
    return super if user.is_admin?
    %i(email)
  end

  def update?
    super || record.id == user.id
  end
end
