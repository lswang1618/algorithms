require 'test_helper'

class PopupControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
