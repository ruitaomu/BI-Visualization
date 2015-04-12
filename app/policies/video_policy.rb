class VideoPolicy < ApplicationPolicy
  def permitted_params
    %i(file tester_id url)
  end
end
