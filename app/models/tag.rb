class Tag < ActiveRecord::Base
  belongs_to :video

  def to_s
    name
  end
end
