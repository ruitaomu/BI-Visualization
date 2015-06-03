class ProjectPolicy < ApplicationPolicy
  def permitted_params
    %i(name type customer_id tester_id archived) + Setting.project_attributes.map { |attr| "metadata_#{attr}" }
  end
end
