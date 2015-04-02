class UploadsController < ApplicationController
  def create
    sleep 5
    render text: 'ok'
  end
end
