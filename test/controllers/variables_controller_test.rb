require 'test_helper'

class VariablesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @variable = variables(:one)
  end

  test "should get typeahead" do
    get :typeahead, id: variables(:autocomplete), project_id: @project, format: 'js'
    assert_not_nil assigns(:variable)
    assert_equal ['Cat', 'Dog', 'Fish'], assigns(:variable).autocomplete_array
    assert_response :success
  end

  test "should get typeahead using authentication token" do
    get :typeahead, id: variables(:external_autocomplete), project_id: sheets(:external).project, sheet_authentication_token: sheets(:external).authentication_token, format: 'js'
    assert_not_nil assigns(:variable)
    assert_equal ['Cat', 'Dog', 'Fish'], assigns(:variable).autocomplete_array
    assert_response :success
  end

  test "should get blank array for non-string typeahead" do
    get :typeahead, id: variables(:dropdown), project_id: @project, format: 'js'
    assert_not_nil assigns(:variable)
    assert_equal [], assigns(:variable).autocomplete_array
    assert_response :success
  end

  test "should add grid row" do
    post :add_grid_row, id: variables(:grid), project_id: @project, format: 'js'
    assert_not_nil assigns(:variable)
    assert_template 'add_grid_row'
    assert_response :success
  end

  test "should add grid row using authentication token" do
    post :add_grid_row, id: variables(:external_grid), project_id: sheets(:external).project, sheet_authentication_token: sheets(:external).authentication_token, format: 'js'
    assert_not_nil assigns(:variable)
    assert_template 'add_grid_row'
    assert_response :success
  end

  test "should not add grid row for user not on project" do
    login(users(:two))
    post :add_grid_row, id: variables(:grid), project_id: @project, format: 'js'
    assert_nil assigns(:variable)
    assert_response :success
  end

  test "should format number" do
    get :format_number, id: variables(:calculated), project_id: @project, calculated_number: "25.359", format: 'js'

    assert_not_nil assigns(:variable)
    assert_equal "25.36", assigns(:result)

    assert_template 'format_number'
  end

  test "should format number on variable with blank format" do
    get :format_number, id: variables(:calculated_without_format), project_id: @project, calculated_number: "25.359", format: 'js'

    assert_not_nil assigns(:variable)
    assert_equal "25.359", assigns(:result)

    assert_template 'format_number'
  end

  test "should format number using authentication token" do
    get :format_number, id: variables(:external_calculated), project_id: sheets(:external).project, sheet_authentication_token: sheets(:external).authentication_token, calculated_number: "25.359", format: 'js'

    assert_not_nil assigns(:variable)
    assert_equal "25.36", assigns(:result)

    assert_template 'format_number'
  end

  test "should not format number for invalid variable" do
    get :format_number, id: -1, project_id: @project, calculated_number: "25.359", format: 'js'

    assert_nil assigns(:variable)
    assert_nil assigns(:result)

    assert_response :success
  end

  test "should get copy" do
    get :copy, id: @variable, project_id: @project
    assert_not_nil assigns(:variable)
    assert_template 'new'
    assert_response :success
  end

  test "should get copy for grid variables" do
    get :copy, id: variables(:grid), project_id: @project
    assert_not_nil assigns(:variable)
    assert_not_nil assigns(:select_variables)
    assert_template 'new'
    assert_response :success
  end

  test "should not copy invalid variable" do
    get :copy, id: -1, project_id: @project
    assert_not_nil assigns(:project)
    assert_nil assigns(:variable)
    assert_redirected_to project_variables_path(assigns(:project))
  end

  test "should not copy variable with invalid project" do
    get :copy, id: @variable, project_id: -1

    assert_nil assigns(:project)
    assert_nil assigns(:variable)

    assert_redirected_to root_path
  end

  # Deprecated
  # test "should add option" do
  #   post :add_option, project_id: @project, variable: { description: @variable.description, header: @variable.header, name: 'var_temp', display_name: 'Variable Temp', options: @variable.options, variable_type: @variable.variable_type }, format: 'js'
  #   assert_not_nil assigns(:variable)
  #   assert_template 'add_option'
  # end

  test "should add grid variable" do
    post :add_grid_variable, project_id: @project, format: 'js'
    assert_not_nil assigns(:select_variables)
    assert_not_nil assigns(:grid_variable)
    assert_template 'add_grid_variable'
  end

  # Deprecated
  # test "should get options" do
  #   post :options, project_id: @project, variable: { description: @variable.description, header: @variable.header, name: 'var_temp', display_name: 'Variable Temp', options: @variable.options, variable_type: @variable.variable_type }, format: 'js'
  #   assert_not_nil assigns(:variable)
  #   assert_template 'options'
  # end

  test "should get index" do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:variables)
  end

  test "should not get index with invalid project" do
    get :index, project_id: -1
    assert_nil assigns(:variables)
    assert_redirected_to root_path
  end

  test "should get paginated index" do
    get :index, project_id: @project, format: 'js'
    assert_not_nil assigns(:variables)
    assert_template 'index'
  end

  test "should get new" do
    get :new, project_id: @project
    assert_not_nil assigns(:variable)
    assert_response :success
  end

  test "should not get new variable with invalid project" do
    get :new, project_id: -1

    assert_nil assigns(:project)
    assert_nil assigns(:variable)

    assert_redirected_to root_path
  end

  test "should create variable" do
    assert_difference('Variable.count') do
      post :create, project_id: @project, variable: { description: @variable.description, header: @variable.header, name: 'var_3', display_name: 'Variable Three', variable_type: @variable.variable_type }
    end

    assert_redirected_to project_variable_path(assigns(:variable).project, assigns(:variable))
  end

  test "should create dropdown variable" do
    assert_difference('Variable.count') do
      post :create, project_id: @project, variable: { name: 'favorite_icecream', display_name: 'Favorite Icecream', variable_type: "dropdown", domain_id: domains(:icecream_flavors).id }
    end

    assert_not_nil assigns(:variable)
    assert_equal 2, assigns(:variable).shared_options.size
    assert_redirected_to project_variable_path(assigns(:variable).project, assigns(:variable))
  end

  test "should not create variable with invalid project" do
    assert_difference('Variable.count', 0) do
      post :create, project_id: -1, variable: { description: @variable.description, header: @variable.header, name: 'var_3', display_name: 'Variable Three', variable_type: @variable.variable_type }
    end

    assert_nil assigns(:project)
    assert_nil assigns(:variable)

    assert_redirected_to root_path
  end

  test "should not create grid variable with non-unique variables" do
    assert_difference('Variable.count', 0) do
      post :create, project_id: @project, variable: { description: @variable.description, header: @variable.header, name: 'var_grid_tmp', display_name: 'Variable Grid', variable_type: 'grid',
                                grid_tokens: [
                                  { variable_id: ActiveRecord::FixtureSet.identify(:integer) },
                                  { variable_id: ActiveRecord::FixtureSet.identify(:integer) }
                                ]
                              }
    end

    assert_not_nil assigns(:variable)
    assert assigns(:variable).errors.size > 0
    assert_equal ["variables must be unique"], assigns(:variable).errors[:grid]
    assert_template 'new'
  end

  test "should show variable" do
    get :show, id: @variable, project_id: @project
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:variable)
    assert_response :success
  end

  test "should not show variable with invalid project" do
    get :show, id: @variable, project_id: -1

    assert_nil assigns(:project)
    assert_nil assigns(:variable)

    assert_redirected_to root_path
  end

  test "should show variable for project with no sites" do
    get :show, id: variables(:no_sites), project_id: projects(:no_sites)
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:variable)
    assert_response :success
  end

  test "should not show invalid variable" do
    get :show, id: -1, project_id: @project
    assert_not_nil assigns(:project)
    assert_nil assigns(:variable)
    assert_redirected_to project_variables_path(assigns(:project))
  end

  test "should get edit" do
    get :edit, id: @variable, project_id: @project
    assert_response :success
  end

  test "should not get edit for invalid variable" do
    get :edit, id: -1, project_id: @project
    assert_not_nil assigns(:project)
    assert_nil assigns(:variable)
    assert_redirected_to project_variables_path
  end

  test "should not get edit with invalid project" do
    get :edit, id: @variable, project_id: -1

    assert_nil assigns(:project)
    assert_nil assigns(:variable)

    assert_redirected_to root_path
  end

  test "should not get edit for site user" do
    login(users(:site_one_user))
    get :edit, id: @variable, project_id: @project

    assert_nil assigns(:variable)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end

  test "should update variable" do
    put :update, id: @variable, project_id: @project, variable: { description: @variable.description, header: @variable.header, name: @variable.name, display_name: @variable.display_name, variable_type: @variable.variable_type }
    assert_redirected_to project_variable_path(assigns(:variable).project, assigns(:variable))
  end

  test "should not update variable with blank display name" do
    put :update, id: @variable, project_id: @project, variable: { description: @variable.description, header: @variable.header, name: @variable.name, display_name: '', variable_type: @variable.variable_type }
    assert_not_nil assigns(:variable)
    assert assigns(:variable).errors.size > 0
    assert_equal ["can't be blank"], assigns(:variable).errors[:display_name]
    assert_template 'edit'
  end

  test "should not update invalid variable" do
    put :update, id: -1, project_id: @project, variable: { description: @variable.description, header: @variable.header, name: @variable.name, display_name: @variable.display_name, variable_type: @variable.variable_type }
    assert_not_nil assigns(:project)
    assert_nil assigns(:variable)
    assert_redirected_to project_variables_path(assigns(:project))
  end

  test "should not update variable with invalid project" do
    put :update, id: @variable, project_id: -1, variable: { description: @variable.description, header: @variable.header, name: @variable.name, display_name: @variable.display_name, variable_type: @variable.variable_type }

    assert_nil assigns(:project)
    assert_nil assigns(:variable)

    assert_redirected_to root_path
  end

  test "should not update variable and remove domain if data has been captured" do
    put :update, id: variables(:data_captured), project_id: variables(:data_captured).project_id, variable: { domain_id: '' }
    assert_not_nil assigns(:variable)
    assert assigns(:variable).errors.size > 0
    assert_equal ["must include all previously captured values"], assigns(:variable).errors[:domain_id]
    assert_template 'edit'
  end

  test "should update variable if switching to a more encompasing domain" do
    put :update, id: variables(:data_captured), project_id: variables(:data_captured).project_id, variable: { domain_id: domains(:three_restaurants) }
    assert_not_nil assigns(:variable)
    assert_equal domains(:three_restaurants), assigns(:variable).domain
    assert_redirected_to project_variable_path(assigns(:variable).project, assigns(:variable))
  end

  test "should update variable if switching to a smaller domain that still encompases the existing data" do
    put :update, id: variables(:data_captured), project_id: variables(:data_captured).project_id, variable: { domain_id: domains(:one_restaurant_encompassing) }
    assert_not_nil assigns(:variable)
    assert_equal domains(:one_restaurant_encompassing), assigns(:variable).domain
    assert_redirected_to project_variable_path(assigns(:variable).project, assigns(:variable))
  end

  test "should not update variable if switching to a domain that doesn't include the captured data" do
    put :update, id: variables(:data_captured), project_id: variables(:data_captured).project_id, variable: { domain_id: domains(:one_restaurant_not_encompassing) }
    assert_not_nil assigns(:variable)
    assert assigns(:variable).errors.size > 0
    assert_equal ["must include all previously captured values"], assigns(:variable).errors[:domain_id]
    assert_template 'edit'
  end

  test "should destroy variable" do
    assert_difference('Variable.current.count', -1) do
      delete :destroy, id: @variable, project_id: @project
    end

    assert_redirected_to project_variables_path(assigns(:project))
  end

  test "should not destroy variable with invalid project" do
    assert_difference('Variable.current.count', 0) do
      delete :destroy, id: @variable, project_id: -1
    end

    assert_nil assigns(:project)
    assert_nil assigns(:variable)

    assert_redirected_to root_path
  end

end
