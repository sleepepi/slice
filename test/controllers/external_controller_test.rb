# frozen_string_literal: true

require "test_helper"

# Tests to assure users can view section images and add grid rows on public
# surveys, and public pages.
class ExternalControllerTest < ActionDispatch::IntegrationTest
  setup do
    @public_design = designs(:admin_public_design)
    @public_section = sections(:public)
    @private_design = designs(:sections_and_variables)
    @private_section = sections(:private)
    @regular = users(:regular)
  end

  test "should get about" do
    get about_url
    assert_response :success
  end

  test "should get about use" do
    get about_use_url
    assert_response :success
  end

  test "should get contact" do
    get contact_url
    assert_response :success
  end

  test "should get landing" do
    get landing_url
    assert_response :success
  end

  test "should add grid row as regular user" do
    login(@regular)
    post external_add_grid_row_url(format: "js"), params: {
      project_id: projects(:one).id,
      design: designs(:has_grid).to_param,
      variable_id: variables(:grid).id,
      design_option_id: design_options(:has_grid_grid).id
    }
    assert_template "add_grid_row"
    assert_response :success
  end

  test "should add grid row on public survey" do
    post external_add_grid_row_url(format: "js"), params: {
      project_id: projects(:three).id,
      design: designs(:admin_public_design).to_param,
      variable_id: variables(:external_grid).id,
      design_option_id: design_options(:admin_public_design_external_grid).id,
      sheet_authentication_token: sheets(:external).authentication_token
    }
    assert_template "add_grid_row"
    assert_response :success
  end

  test "should add grid row for site editor" do
    login(users(:site_one_editor))
    post external_add_grid_row_url(format: "js"), params: {
      project_id: projects(:one).id,
      design: designs(:has_grid).to_param,
      variable_id: variables(:grid).id,
      design_option_id: design_options(:has_grid_grid).id
    }
    assert_template "add_grid_row"
    assert_response :success
  end

  test "should not add grid row for user not on project" do
    login(users(:two))
    post external_add_grid_row_url(format: "js"), params: {
      project_id: projects(:one).id,
      design: designs(:has_grid).to_param,
      variable_id: variables(:grid).id,
      design_option_id: design_options(:has_grid_grid).id
    }
    assert_response :success
  end

  test "should add grid row for handoff" do
    post external_add_grid_row_url(format: "js"), params: {
      project_id: projects(:one).id,
      design: designs(:has_grid).to_param,
      variable_id: variables(:grid).id,
      design_option_id: design_options(:has_grid_grid).id,
      handoff: handoffs(:grid).to_param
    }
    assert_template "add_grid_row"
    assert_response :success
  end

  test "should add grid row for assignment" do
    login(users(:aes_team_reviewer))
    post external_add_grid_row_url(format: "js"), params: {
      project_id: projects(:aes).id,
      design: designs(:aes_mild_adjudication).to_param,
      variable_id: variables(:aes_grid).id,
      design_option_id: design_options(:aes_grid).id,
      assignment_id: ae_assignments(:aes_pathset_reviewer_one).id
    }
    assert_template "add_grid_row"
    assert_response :success
  end

  test "should get section image from public design as public viewer" do
    get external_section_image_url(section_id: @public_section.id, project_id: projects(:three).id, design: @public_design)
    assert_equal File.binread(assigns(:section).image.path), response.body
  end

  test "should get section image from handoff" do
    @handoff = handoffs(:one)
    @design = designs(:sections_and_variables)
    @section = sections(:private)
    get external_section_image_url(section_id: @section.id, project_id: projects(:one).id, design: @design, handoff: @handoff)
    assert_equal File.binread(assigns(:section).image.path), response.body
  end

  test "should get section image from design as regular user" do
    login(@regular)
    get external_section_image_url(section_id: @private_section.id, project_id: projects(:one).id, design: @private_design)
    assert_equal File.binread(assigns(:section).image.path), response.body
  end

  test "should not get section image from private design without login" do
    get external_section_image_url(section_id: @private_section.id, project_id: projects(:one).id, design: @private_design)
    assert_response :success
  end

  test "should get sitemap xml file" do
    get sitemap_xml_url
    assert_response :success
  end

  test "should get privacy policy" do
    get privacy_policy_url
    assert_response :success
  end

  test "should get term of service" do
    get terms_of_service_url
    assert_response :success
  end

  test "should get version" do
    get version_url
    assert_response :success
  end

  test "should get version as json" do
    get version_url(format: "json")
    version = JSON.parse(response.body)
    assert_equal Slice::VERSION::STRING, version["version"]["string"]
    assert_equal Slice::VERSION::MAJOR, version["version"]["major"]
    assert_equal Slice::VERSION::MINOR, version["version"]["minor"]
    assert_equal Slice::VERSION::TINY, version["version"]["tiny"]
    if Slice::VERSION::BUILD.nil?
      assert_nil version["version"]["build"]
    else
      assert_equal Slice::VERSION::BUILD, version["version"]["build"]
    end
    assert_response :success
  end
end
