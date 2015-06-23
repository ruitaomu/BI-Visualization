class TagPolicy < ApplicationPolicy
  def permitted_params
    %i(name video_id parent_id)
  end
end