require 'test_helper'

class SectionsControllerTest < ActionController::TestCase
  setup do
    @private_section = sections(:private)
    @private_design = designs(:sections_and_variables)
  end

  test "should get section image from private design as regular user" do
    login(users(:valid))
    get :image, project_id: @private_design.project_id, design_id: @private_design.id, id: @private_section.id

    assert_not_nil response
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:section)

    assert_kind_of String, response.body
    assert_equal File.binread( File.join(CarrierWave::Uploader::Base.root, assigns(:section).image.url) ), response.body
  end

  test "should not get image from private design without login" do
    get :image, project_id: @private_design.project_id, design_id: @private_design.id, id: @private_section.id

    assert_nil assigns(:project)
    assert_nil assigns(:design)
    assert_nil assigns(:section)

    assert_redirected_to new_user_session_path
  end

  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:sections)
  # end

  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

  # test "should create section" do
  #   assert_difference('Section.count') do
  #     post :create, section: {  }
  #   end

  #   assert_redirected_to section_path(assigns(:section))
  # end

  # test "should show section" do
  #   get :show, id: @section
  #   assert_response :success
  # end

  # test "should get edit" do
  #   get :edit, id: @section
  #   assert_response :success
  # end

  # test "should update section" do
  #   patch :update, id: @section, section: {  }
  #   assert_redirected_to section_path(assigns(:section))
  # end

  # test "should destroy section" do
  #   assert_difference('Section.count', -1) do
  #     delete :destroy, id: @section
  #   end

  #   assert_redirected_to sections_path
  # end
end
