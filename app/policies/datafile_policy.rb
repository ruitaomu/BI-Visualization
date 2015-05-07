class DatafilePolicy < ApplicationPolicy
  def permitted_params
    %i(video_id moving_average)
  end
end
