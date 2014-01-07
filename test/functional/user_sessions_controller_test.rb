require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  def setup
    stub_solr
  end

  test "should get new" do
    get :new
    assert_response :success
  end
end
