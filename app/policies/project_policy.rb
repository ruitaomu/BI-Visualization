class ProjectPolicy < ApplicationPolicy
  def permitted_params
    %i(name type customer_id tester_id)
  end
end
