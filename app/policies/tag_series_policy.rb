class TagSeriesPolicy < ApplicationPolicy
  def permitted_params
    %i(name video_id tag_ids)
  end
end