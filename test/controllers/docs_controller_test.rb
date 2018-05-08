# frozen_string_literal: true

require "test_helper"

# Tests to assure documentation pages can be publicly viewed.
class DocsControllerTest < ActionDispatch::IntegrationTest
  test "should get docs index" do
    get docs_path
    assert_response :success
  end

  test "should get modules" do
    get docs_modules_path
    assert_response :success
  end

  test "should get adverse events" do
    get docs_adverse_events_path
    assert_response :success
  end

  test "should get tablet handoff" do
    get docs_tablet_handoff_path
    assert_response :success
  end

  test "should get roles" do
    get docs_roles_path
    assert_response :success
  end

  test "should get notifications" do
    get docs_notifications_path
    assert_response :success
  end

  test "should get blinding" do
    get docs_blinding_path
    assert_response :success
  end

  test "should get sites" do
    get docs_sites_path
    assert_response :success
  end

  test "should get data review and analysis" do
    get docs_data_review_path
    assert_response :success
  end

  test "should get technical" do
    get docs_technical_path
    assert_response :success
  end

  test "should get randomization schemes" do
    get docs_randomization_schemes_path
    assert_response :success
  end

  test "should get minimization" do
    get docs_minimization_path
    assert_response :success
  end

  test "should get permuted block" do
    get docs_permuted_block_path
    assert_response :success
  end

  test "should get designs" do
    get docs_designs_path
    assert_response :success
  end

  test "should get sections" do
    get docs_sections_path
    assert_response :success
  end

  test "should get variables" do
    get docs_variables_path
    assert_response :success
  end

  test "should get domains" do
    get docs_domains_path
    assert_response :success
  end

  test "should get treatment arms" do
    get docs_treatment_arms_path
    assert_response :success
  end

  test "should get stratification factors" do
    get docs_stratification_factors_path
    assert_response :success
  end

  test "should get checks" do
    get docs_checks_path
    assert_response :success
  end

  test "should get exports" do
    get docs_exports_path
    assert_response :success
  end

  test "should get reports" do
    get docs_reports_path
    assert_response :success
  end

  test "should get sheets" do
    get docs_sheets_path
    assert_response :success
  end

  test "should get locking" do
    get docs_locking_path
    assert_response :success
  end

  test "should get events" do
    get docs_events_path
    assert_response :success
  end

  test "should get project setup" do
    get docs_project_setup_path
    assert_response :success
  end

  test "should get filters" do
    get docs_filters_path
    assert_response :success
  end
end
