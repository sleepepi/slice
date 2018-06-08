# frozen_string_literal: true

require "test_helper"

# Assure that randomizations can be viewed and created.
class RandomizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_one_editor = users(:project_one_editor)
    @site_one_editor = users(:site_one_editor)
    @site_one_viewer = users(:site_one_viewer)

    @project_two_editor = users(:regular)
    @site_two_editor = users(:site_two_editor)
    @site_two_viewer = users(:site_two_viewer)

    @project = projects(:one)
    @randomization = randomizations(:one)
  end

  test "should get choose scheme and choose single published randomization scheme" do
    login(@project_one_editor)
    get choose_scheme_project_randomizations_url(@project)
    assert_redirected_to(
      randomize_subject_project_randomization_scheme_url(assigns(:project), randomization_schemes(:one))
    )
  end

  test "should get choose scheme and give options to multiple published randomization schemes" do
    login(@project_two_editor)
    get choose_scheme_project_randomizations_url(projects(:two))
    assert_response :success
  end

  test "should get choose scheme for site editor" do
    login(@site_two_editor)
    get choose_scheme_project_randomizations_url(projects(:two))
    assert_response :success
  end

  test "should not get choose scheme for site viewer" do
    login(@site_two_viewer)
    get choose_scheme_project_randomizations_url(projects(:two))
    assert_redirected_to root_url
  end

  test "should get export as project editor" do
    login(@project_one_editor)
    get export_project_randomizations_url(@project)
    assert_redirected_to [assigns(:project), assigns(:export)]
  end

  test "should get index" do
    login(@project_one_editor)
    get project_randomizations_url(@project)
    assert_response :success
  end

  test "should get index for site editor" do
    login(@site_one_editor)
    get project_randomizations_url(@project)
    assert_response :success
  end

  test "should get index ordered by scheme" do
    login(@site_one_editor)
    get project_randomizations_url(@project), params: { order: "scheme" }
    assert_response :success
  end

  test "should get index ordered by scheme desc" do
    login(@site_one_editor)
    get project_randomizations_url(@project), params: { order: "scheme desc" }
    assert_response :success
  end

  test "should get index ordered by site" do
    login(@site_one_editor)
    get project_randomizations_url(@project), params: { order: "site" }
    assert_response :success
  end

  test "should get index ordered by site desc" do
    login(@site_one_editor)
    get project_randomizations_url(@project), params: { order: "site desc" }
    assert_response :success
  end

  test "should get index ordered by treament arm" do
    login(@site_one_editor)
    get project_randomizations_url(@project), params: { order: "arm" }
    assert_response :success
  end

  test "should get index ordered by treament arm desc" do
    login(@site_one_editor)
    get project_randomizations_url(@project), params: { order: "arm desc" }
    assert_response :success
  end

  test "should get index ordered by randomized" do
    login(@site_one_editor)
    get project_randomizations_url(@project), params: { order: "randomized" }
    assert_response :success
  end

  test "should get index ordered by randomized desc" do
    login(@site_one_editor)
    get project_randomizations_url(@project), params: { order: "randomized desc" }
    assert_response :success
  end

  test "should get index ordered by randomized by" do
    login(@site_one_editor)
    get project_randomizations_url(@project), params: { order: "randomized_by" }
    assert_response :success
  end

  test "should get index ordered by randomized by desc" do
    login(@site_one_editor)
    get project_randomizations_url(@project), params: { order: "randomized_by desc" }
    assert_response :success
  end

  test "should get index ordered by subject code" do
    login(@site_one_editor)
    get project_randomizations_url(@project), params: { order: "subject" }
    assert_response :success
  end

  test "should get index ordered by subject code desc" do
    login(@site_one_editor)
    get project_randomizations_url(@project), params: { order: "subject desc" }
    assert_response :success
  end

  test "should get index for site viewer" do
    login(@site_one_viewer)
    get project_randomizations_url(@project)
    assert_response :success
  end

  test "should show randomization" do
    login(@project_one_editor)
    get project_randomization_url(@project, @randomization)
    assert_response :success
  end

  test "should show randomization for site editor" do
    login(@site_one_editor)
    get project_randomization_url(@project, @randomization)
    assert_response :success
  end

  test "should show randomization for site viewer" do
    login(@site_one_viewer)
    get project_randomization_url(@project, @randomization)
    assert_response :success
  end

  test "should show randomization for minimization scheme" do
    login(@project_two_editor)
    get project_randomization_url(projects(:two), randomizations(:min_one))
    assert_response :success
  end

  test "should print randomization schedule for site editor" do
    skip if ENV["TRAVIS"] # Skip this test on Travis since Travis can't generate PDFs
    login(@site_one_editor)
    get schedule_project_randomization_url(@project, @randomization, format: "pdf")
    assert_response :success
  end

  test "should print randomization schedule for site viewer" do
    skip if ENV["TRAVIS"] # Skip this test on Travis since Travis can't generate PDFs
    login(@site_one_viewer)
    get schedule_project_randomization_url(@project, @randomization, format: "pdf")
    assert_response :success
  end

  test "should show empty response if schedule PDF fails to render" do
    skip if ENV["TRAVIS"] # Skip this test on Travis since Travis can't generate PDFs
    begin
      original_latex = ENV["latex_location"]
      ENV["latex_location"] = "echo #{original_latex}"
      login(@site_one_editor)
      get schedule_project_randomization_url(@project, randomizations(:two), format: "pdf")
      assert_response :ok
    ensure
      ENV["latex_location"] = original_latex
    end
  end

  test "should undo randomization" do
    login(@project_one_editor)
    patch undo_project_randomization_url(@project, @randomization)
    @randomization.reload
    assert_nil @randomization.subject_id
    assert_nil @randomization.randomized_by_id
    assert_nil @randomization.randomized_at
    assert_redirected_to project_randomizations_url(@project)
  end

  test "should not undo randomization as site editor" do
    login(@site_one_editor)
    patch undo_project_randomization_url(@project, @randomization)
    assert_redirected_to project_randomizations_url(@project)
  end

  # test "should destroy randomization" do
  #   login(@project_one_editor)
  #   assert_difference("Randomization.current.count", -1) do
  #     delete project_randomization_url(@project, @randomization)
  #   end
  #   assert_redirected_to project_randomizations_url(@project)
  # end
end
