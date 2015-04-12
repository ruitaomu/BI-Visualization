require 'test_helper'

class S3SignaturesControllerTest < ActionController::TestCase
  test "should get create" do
    get :create
    assert_response :success
  end

end
