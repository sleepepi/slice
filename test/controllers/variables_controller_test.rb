# frozen_string_literal: true

require 'test_helper'

# Tests to assure project editors can view and modify variables.
class VariablesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @variable = variables(:one)
  end

  test 'should get report lookup' do
    post :report_lookup, params: { variable_id: 'sheet_date', project_id: @project }, format: 'js'
    assert_template 'report_lookup'
    assert_response :success
  end

  test 'should get copy' do
    get :copy, params: { id: @variable, project_id: @project }
    assert_not_nil assigns(:variable)
    assert_template 'new'
    assert_response :success
  end

  test 'should get copy for grid variables' do
    get :copy, params: { id: variables(:grid), project_id: @project }
    assert_not_nil assigns(:variable)
    assert_template 'new'
    assert_response :success
  end

  test 'should not copy invalid variable' do
    get :copy, params: { id: -1, project_id: @project }
    assert_not_nil assigns(:project)
    assert_nil assigns(:variable)
    assert_redirected_to project_variables_path(assigns(:project))
  end

  test 'should not copy variable with invalid project' do
    get :copy, params: { id: @variable, project_id: -1 }

    assert_nil assigns(:project)
    assert_nil assigns(:variable)

    assert_redirected_to root_path
  end

  test 'should add grid variable' do
    post :add_grid_variable, params: { project_id: @project }, format: 'js'
    assert_not_nil assigns(:grid_variable)
    assert_template 'add_grid_variable'
  end

  test 'should get index' do
    get :index, params: { project_id: @project }
    assert_response :success
    assert_not_nil assigns(:variables)
  end

  test 'should not get index with invalid project' do
    get :index, params: { project_id: -1 }
    assert_nil assigns(:variables)
    assert_redirected_to root_path
  end

  test 'should get paginated index' do
    get :index, params: { project_id: @project }, format: 'js'
    assert_not_nil assigns(:variables)
    assert_template 'index'
    assert_response :success
  end

  test 'should get new' do
    get :new, params: { project_id: @project }
    assert_not_nil assigns(:variable)
    assert_response :success
  end

  test 'should not get new variable with invalid project' do
    get :new, params: { project_id: -1 }
    assert_nil assigns(:project)
    assert_nil assigns(:variable)
    assert_redirected_to root_path
  end

  test 'should create variable' do
    assert_difference('Variable.count') do
      post :create, params: {
        project_id: @project,
        variable: {
          description: @variable.description, name: 'var_3',
          display_name: 'Variable Three', variable_type: @variable.variable_type
        }
      }
    end
    assert_redirected_to project_variable_path(assigns(:variable).project, assigns(:variable))
  end

  test 'should create variable and continue' do
    assert_difference('Variable.count') do
      post :create, params: {
        project_id: @project, continue: '1',
        variable: {
          description: @variable.description, name: 'var_4',
          display_name: 'Variable Four', variable_type: @variable.variable_type
        }
      }
    end

    assert_redirected_to new_project_variable_path(assigns(:variable).project)
  end

  test 'should create dropdown variable' do
    assert_difference('Variable.count') do
      post :create, params: {
        project_id: @project,
        variable: {
          name: 'favorite_icecream', display_name: 'Favorite Icecream',
          variable_type: 'dropdown', domain_id: domains(:icecream_flavors).id
        }
      }
    end

    assert_not_nil assigns(:variable)
    assert_equal 2, assigns(:variable).shared_options.size
    assert_redirected_to project_variable_path(assigns(:variable).project, assigns(:variable))
  end

  test 'should create string variable without a domain' do
    assert_difference('Variable.count') do
      post :create, params: {
        project_id: @project, variable: {
          name: 'restaurant', display_name: 'Favorite Restaurant',
          variable_type: 'string', domain_id: domains(:icecream_flavors).id
        }
      }
    end
    assert_not_nil assigns(:variable)
    assert_equal 0, assigns(:variable).shared_options.size
    assert_nil assigns(:variable).domain
    assert_redirected_to project_variable_path(assigns(:variable).project, assigns(:variable))
  end

  test 'should not create variable with invalid project' do
    assert_difference('Variable.count', 0) do
      post :create, params: {
        project_id: -1, variable: {
          description: @variable.description, name: 'var_3',
          display_name: 'Variable Three', variable_type: @variable.variable_type
        }
      }
    end
    assert_nil assigns(:project)
    assert_nil assigns(:variable)
    assert_redirected_to root_path
  end

  test 'should not create grid variable with nonunique variables' do
    assert_difference('Variable.count', 0) do
      post :create, params: {
        project_id: @project,
        variable: {
          description: @variable.description,
          name: 'var_grid_tmp',
          display_name: 'Variable Grid',
          variable_type: 'grid',
          grid_tokens: [
            { variable_id: ActiveRecord::FixtureSet.identify(:integer) },
            { variable_id: ActiveRecord::FixtureSet.identify(:integer) }
          ]
        }
      }
    end

    assert_not_nil assigns(:variable)
    assert assigns(:variable).errors.size > 0
    assert_equal ['variables must be unique'], assigns(:variable).errors[:grid]
    assert_template 'new'
  end

  test 'should show variable' do
    get :show, params: { id: @variable, project_id: @project }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:variable)
    assert_response :success
  end

  test 'should show scale variable' do
    get :show, params: {
      project_id: variables(:change_domain_options).project_id,
      id: variables(:change_domain_options)
    }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:variable)
    assert_response :success
  end

  test 'should not show variable with invalid project' do
    get :show, params: { id: @variable, project_id: -1 }
    assert_nil assigns(:project)
    assert_nil assigns(:variable)
    assert_redirected_to root_path
  end

  test 'should show variable for project with no sites' do
    get :show, params: {
      project_id: projects(:no_sites),
      id: variables(:no_sites)
    }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:variable)
    assert_response :success
  end

  test 'should not show invalid variable' do
    get :show, params: { id: -1, project_id: @project }
    assert_not_nil assigns(:project)
    assert_nil assigns(:variable)
    assert_redirected_to project_variables_path(assigns(:project))
  end

  test 'should get edit' do
    get :edit, params: { id: @variable, project_id: @project }
    assert_response :success
  end

  test 'should not get edit for invalid variable' do
    get :edit, params: { id: -1, project_id: @project }
    assert_not_nil assigns(:project)
    assert_nil assigns(:variable)
    assert_redirected_to project_variables_path
  end

  test 'should not get edit with invalid project' do
    get :edit, params: { id: @variable, project_id: -1 }

    assert_nil assigns(:project)
    assert_nil assigns(:variable)

    assert_redirected_to root_path
  end

  test 'should not get edit for site user' do
    login(users(:site_one_viewer))
    get :edit, params: { id: @variable, project_id: @project }

    assert_nil assigns(:variable)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end

  test 'should update variable' do
    patch :update, params: {
      id: @variable, project_id: @project,
      variable: {
        description: @variable.description, name: @variable.name,
        display_name: @variable.display_name
      }
    }
    assert_redirected_to project_variable_path(assigns(:variable).project, assigns(:variable))
  end

  test 'should update variable and continue' do
    patch :update, params: {
      id: @variable, project_id: @project, continue: '1',
      variable: {
        description: @variable.description, name: @variable.name,
        display_name: @variable.display_name
      }
    }
    assert_redirected_to new_project_variable_path(assigns(:variable).project)
  end

  test 'should not update variable with blank display name' do
    patch :update, params: {
      id: @variable, project_id: @project,
      variable: {
        description: @variable.description, name: @variable.name,
        display_name: '', variable_type: @variable.variable_type
      }
    }
    assert_not_nil assigns(:variable)
    assert assigns(:variable).errors.size > 0
    assert_equal ['can\'t be blank'], assigns(:variable).errors[:display_name]
    assert_template 'edit'
  end

  test 'should not update invalid variable' do
    patch :update, params: {
      id: -1, project_id: @project,
      variable: {
        description: @variable.description, name: @variable.name,
        display_name: @variable.display_name, variable_type: @variable.variable_type
      }
    }
    assert_not_nil assigns(:project)
    assert_nil assigns(:variable)
    assert_redirected_to project_variables_path(assigns(:project))
  end

  test 'should not update variable with invalid project' do
    patch :update, params: {
      id: @variable, project_id: -1,
      variable: {
        description: @variable.description, name: @variable.name,
        display_name: @variable.display_name, variable_type: @variable.variable_type
      }
    }
    assert_nil assigns(:project)
    assert_nil assigns(:variable)
    assert_redirected_to root_path
  end

  test 'should not update variable and remove domain if data has been captured' do
    patch :update, params: {
      project_id: variables(:data_captured).project_id,
      id: variables(:data_captured),
      variable: { domain_id: '' }
    }
    assert_not_nil assigns(:variable)
    assert assigns(:variable).errors.size > 0
    assert_equal ['must include all previously captured values'], assigns(:variable).errors[:domain_id]
    assert_template 'edit'
  end

  test 'should update variable if switching to a more encompasing domain' do
    patch :update, params: {
      project_id: variables(:data_captured).project_id,
      id: variables(:data_captured),
      variable: { domain_id: domains(:three_restaurants) }
    }
    assert_not_nil assigns(:variable)
    assert_equal domains(:three_restaurants), assigns(:variable).domain
    assert_redirected_to project_variable_path(assigns(:variable).project, assigns(:variable))
  end

  test 'should update variable if switching to a smaller domain that still encompases the existing data' do
    patch :update, params: {
      project_id: variables(:data_captured).project_id,
      id: variables(:data_captured),
      variable: { domain_id: domains(:one_restaurant_encompassing) }
    }
    assert_not_nil assigns(:variable)
    assert_equal domains(:one_restaurant_encompassing), assigns(:variable).domain
    assert_redirected_to project_variable_path(assigns(:variable).project, assigns(:variable))
  end

  test 'should not update variable if switching to a domain that does not include the captured data' do
    patch :update, params: {
      project_id: variables(:data_captured).project_id,
      id: variables(:data_captured),
      variable: { domain_id: domains(:one_restaurant_not_encompassing) }
    }
    assert_not_nil assigns(:variable)
    assert assigns(:variable).errors.size > 0
    assert_equal ['must include all previously captured values'], assigns(:variable).errors[:domain_id]
    assert_template 'edit'
  end

  test 'should update variable if switching to a domain that includes the captured data for numerics and integers' do
    patch :update, params: {
      project_id: variables(:data_captured).project_id,
      id: variables(:data_captured),
      variable: {
        domain_id: domains(:one_restaurant_not_encompassing),
        variable_type: 'integer'
      }
    }
    assert_not_nil assigns(:variable)
    assert_equal 'integer', assigns(:variable).variable_type
    assert_equal domains(:one_restaurant_not_encompassing), assigns(:variable).domain
    assert_redirected_to project_variable_path(assigns(:variable).project, assigns(:variable))
  end

  test 'should destroy variable' do
    assert_difference('Variable.current.count', -1) do
      delete :destroy, params: { project_id: @project, id: @variable }
    end
    assert_redirected_to project_variables_path(assigns(:project))
  end

  test 'should not destroy variable with invalid project' do
    assert_difference('Variable.current.count', 0) do
      delete :destroy, params: { project_id: -1, id: @variable }
    end
    assert_nil assigns(:project)
    assert_nil assigns(:variable)
    assert_redirected_to root_path
  end

  test 'should restore deleted variable' do
    assert_difference('Variable.current.count') do
      post :restore, params: { project_id: @project, id: variables(:deleted) }
    end
    assert_redirected_to [@project, variables(:deleted)]
  end
end
