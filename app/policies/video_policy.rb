class VideoPolicy < ApplicationPolicy
  def permitted_params
    %i(file)
  end

  def visible_attributes
    %i(file)
  end
end
