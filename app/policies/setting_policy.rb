class SettingPolicy < ApplicationPolicy
  # To simplify things only the admin is allowed to control
  # this model (per ApplicationPolicy's defaults),so define it as such.

  def permitted_params
    %i(value)
  end

  def permitted_param?(param)
    true
  end

  def destroy?
    false
  end
end
