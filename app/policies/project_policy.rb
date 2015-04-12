class ProjectPolicy < ApplicationPolicy
  def permitted_params
    %i(name customer_id tester_id)
  end
end
