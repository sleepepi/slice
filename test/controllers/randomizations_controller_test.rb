# frozen_string_literal: true

require 'test_helper'

# Assure that randomizations can be viewed and created.
class RandomizationsControllerTest < ActionController::TestCase
  setup do
    @project = projects(:one)
    @randomization = randomizations(:one)
  end

  test 'should get choose scheme and choose single published randomization scheme' do
    login(users(:valid))
    get :choose_scheme, params: { project_id: @project }
    assert_redirected_to(
      randomize_subject_project_randomization_scheme_path(assigns(:project), randomization_schemes(:one))
    )
  end

  test 'should get choose scheme and give options to multiple published randomization schemes' do
    login(users(:valid))
    get :choose_scheme, params: { project_id: projects(:two) }
    assert_response :success
  end

  test 'should get choose scheme for site editor' do
    login(users(:site_two_editor))
    get :choose_scheme, params: { project_id: projects(:two) }
    assert_response :success
  end

  test 'should not get choose scheme for site viewer' do
    login(users(:site_two_viewer))
    get :choose_scheme, params: { project_id: projects(:two) }
    assert_redirected_to root_path
  end

  test 'should get export as project editor' do
    login(users(:valid))
    get :export, params: { project_id: @project }
    assert_redirected_to [assigns(:project), assigns(:export)]
  end

  test 'should get index' do
    login(users(:valid))
    get :index, params: { project_id: @project }
    assert_response :success
    assert_not_nil assigns(:randomizations)
  end

  test 'should get index for site editor' do
    login(users(:site_one_editor))
    get :index, params: { project_id: @project }
    assert_response :success
    assert_not_nil assigns(:randomizations)
  end

  test 'should get index ordered by scheme' do
    login(users(:site_one_editor))
    get :index, params: { project_id: @project, order: 'scheme' }
    assert_response :success
    assert_not_nil assigns(:randomizations)
  end

  test 'should get index ordered by scheme desc' do
    login(users(:site_one_editor))
    get :index, params: { project_id: @project, order: 'scheme desc' }
    assert_response :success
    assert_not_nil assigns(:randomizations)
  end

  test 'should get index ordered by site' do
    login(users(:site_one_editor))
    get :index, params: { project_id: @project, order: 'site' }
    assert_response :success
    assert_not_nil assigns(:randomizations)
  end

  test 'should get index ordered by site desc' do
    login(users(:site_one_editor))
    get :index, params: { project_id: @project, order: 'site desc' }
    assert_response :success
    assert_not_nil assigns(:randomizations)
  end

  test 'should get index ordered by treament arm' do
    login(users(:site_one_editor))
    get :index, params: { project_id: @project, order: 'arm' }
    assert_response :success
    assert_not_nil assigns(:randomizations)
  end

  test 'should get index ordered by treament arm desc' do
    login(users(:site_one_editor))
    get :index, params: { project_id: @project, order: 'arm desc' }
    assert_response :success
    assert_not_nil assigns(:randomizations)
  end

  test 'should get index ordered by randomized' do
    login(users(:site_one_editor))
    get :index, params: { project_id: @project, order: 'randomized' }
    assert_response :success
    assert_not_nil assigns(:randomizations)
  end

  test 'should get index ordered by randomized desc' do
    login(users(:site_one_editor))
    get :index, params: { project_id: @project, order: 'randomized desc' }
    assert_response :success
    assert_not_nil assigns(:randomizations)
  end

  test 'should get index ordered by randomized by' do
    login(users(:site_one_editor))
    get :index, params: { project_id: @project, order: 'randomized_by' }
    assert_response :success
    assert_not_nil assigns(:randomizations)
  end

  test 'should get index ordered by randomized by desc' do
    login(users(:site_one_editor))
    get :index, params: { project_id: @project, order: 'randomized_by desc' }
    assert_response :success
    assert_not_nil assigns(:randomizations)
  end

  test 'should get index ordered by subject code' do
    login(users(:site_one_editor))
    get :index, params: { project_id: @project, order: 'subject' }
    assert_response :success
    assert_not_nil assigns(:randomizations)
  end

  test 'should get index ordered by subject code desc' do
    login(users(:site_one_editor))
    get :index, params: { project_id: @project, order: 'subject desc' }
    assert_response :success
    assert_not_nil assigns(:randomizations)
  end

  test 'should get index for site viewer' do
    login(users(:site_one_viewer))
    get :index, params: { project_id: @project }
    assert_response :success
    assert_not_nil assigns(:randomizations)
  end

  test 'should show randomization' do
    login(users(:valid))
    get :show, params: { project_id: @project, id: @randomization }
    assert_response :success
  end

  test 'should show randomization for site editor' do
    login(users(:site_one_editor))
    get :show, params: { project_id: @project, id: @randomization }
    assert_response :success
  end

  test 'should show randomization for site viewer' do
    login(users(:site_one_viewer))
    get :show, params: { project_id: @project, id: @randomization }
    assert_response :success
  end

  test 'should show randomization for minimization scheme' do
    login(users(:valid))
    get :show, params: {
      project_id: projects(:two), id: randomizations(:min_one)
    }
    assert_response :success
  end

  test 'should print randomization schedule for site editor' do
    skip if ENV['TRAVIS'] # Skip this test on Travis since Travis can't generate PDFs
    login(users(:site_one_editor))
    get :schedule, params: {
      project_id: @project, id: @randomization
    }, format: 'pdf'
    assert_not_nil assigns(:randomization)
    assert_response :success
  end

  test 'should print randomization schedule for site viewer' do
    skip if ENV['TRAVIS'] # Skip this test on Travis since Travis can't generate PDFs
    login(users(:site_one_viewer))
    get :schedule, params: {
      project_id: @project, id: @randomization
    }, format: 'pdf'
    assert_not_nil assigns(:randomization)
    assert_response :success
  end

  test 'should show randomization if PDF fails to render' do
    skip if ENV['TRAVIS'] # Skip this test on Travis since Travis can't generate PDFs
    begin
      original_latex = ENV['latex_location']
      ENV['latex_location'] = "echo #{original_latex}"
      login(users(:site_one_editor))
      get :schedule, params: {
        project_id: @project, id: randomizations(:two)
      }, format: 'pdf'
      assert_not_nil assigns(:randomization)
      assert_redirected_to [@project, randomizations(:two)]
    ensure
      ENV['latex_location'] = original_latex
    end
  end

  test 'should undo randomization' do
    login(users(:valid))
    patch :undo, params: { project_id: @project, id: @randomization }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:randomization)
    assert_nil assigns(:randomization).subject_id
    assert_nil assigns(:randomization).randomized_by_id
    assert_nil assigns(:randomization).randomized_at
    assert_redirected_to project_randomizations_path(assigns(:project))
  end

  test 'should not undo randomization as site editor' do
    login(users(:site_one_editor))
    patch :undo, params: { project_id: @project, id: @randomization }
    assert_not_nil assigns(:project)
    assert_nil assigns(:randomization)
    assert_redirected_to project_randomizations_path(assigns(:project))
  end

  # test 'should destroy randomization' do
  #   assert_difference('Randomization.current.count', -1) do
  #     delete :destroy, project_id: @project, id: @randomization
  #   end

  #   assert_redirected_to project_randomizations_path(assigns(:project))
  # end
end
