class VideoPolicy < ApplicationPolicy
  def permitted_params
    %i(file tester_id url) + [{ tags_attributes: %i(id name group starts ends parent_id _destroy) }] + [ { datafile_attributes: %i(id video_id moving_average file threshold) }]
  end
end
