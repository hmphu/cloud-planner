require 'test_helper'

class PlansControllerTest < ActionDispatch::IntegrationTest
  test "should get calculate" do
    get plans_calculate_url
    assert_response :success
  end

end
