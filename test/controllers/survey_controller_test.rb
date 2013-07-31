require 'test_helper'

class SurveyControllerTest < ActionController::TestCase

  test "should get survey with slug" do
    get :show, slug: designs(:admin_public_design).slug
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_equal true, assigns(:design).publicly_available
    assert_response :success
  end

  test "should not get private survey" do
    assert_equal false, designs(:admin_design).publicly_available
    get :show, slug: designs(:admin_design).slug
    assert_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to about_path
  end

end
