# frozen_string_literal: true

require "test_helper"

class CubesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular = users(:regular)
    @tray = trays(:one)
    @cube = cubes(:one)
  end

  def cube_params
    {
      cube_type: @cube.cube_type,
      description: @cube.description,
      tray_id: @cube.tray_id,
      text: @cube.text
    }
  end

  test "should get index" do
    login(@regular)
    get tray_cubes_url(@regular.profile, @tray)
    assert_response :success
  end

  test "should get new" do
    login(@regular)
    get new_tray_cube_url(@regular.profile, @tray)
    assert_response :success
  end

  test "should create cube" do
    login(@regular)
    assert_difference("Cube.count") do
      post tray_cubes_url(@regular.profile, @tray), params: { cube: cube_params }
    end
    assert_redirected_to tray_cube_url(@regular.profile, @tray, Cube.last)
  end

  test "should show cube" do
    login(@regular)
    get tray_cube_url(@regular.profile, @tray, @cube)
    assert_response :success
  end

  test "should get edit" do
    login(@regular)
    get edit_tray_cube_url(@regular.profile, @tray, @cube)
    assert_response :success
  end

  test "should update cube" do
    login(@regular)
    patch tray_cube_url(@regular.profile, @tray, @cube), params: { cube: cube_params }
    assert_redirected_to tray_cube_url(@regular.profile, @tray, @cube)
  end

  test "should destroy cube" do
    login(@regular)
    assert_difference("Cube.count", -1) do
      delete tray_cube_url(@regular.profile, @tray, @cube)
    end
    assert_redirected_to tray_cubes_url(@regular.profile, @tray)
  end
end
