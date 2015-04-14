class VideoPolicy < ApplicationPolicy
  def permitted_params
    %i(file tester_id url) + [{ tags_attributes: %i(id name starts ends _destroy) }]
  end
end
