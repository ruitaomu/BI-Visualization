class TesterPolicy < ApplicationPolicy
  def permitted_params
    %i(name) + Setting.tester_attributes.map { |attr| "metadata_#{attr}" }
  end
end
