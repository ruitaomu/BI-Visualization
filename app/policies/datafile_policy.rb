class DatafilePolicy < ApplicationPolicy
  def permitted_params
    %i(video_id moving_average threshold)
  end
end
