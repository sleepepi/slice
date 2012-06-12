require 'test_helper'

class VariablesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @variable = variables(:one)
  end

  test "should get copy" do
    get :copy, id: @variable
    assert_not_nil assigns(:variable)
    assert_template 'new'
    assert_response :success
  end

  test "should add option" do
    post :add_option, variable: { description: @variable.description, header: @variable.header, name: 'var_temp', display_name: 'Variable Temp', options: @variable.options, variable_type: @variable.variable_type }, format: 'js'
    assert_not_nil assigns(:variable)
    assert_not_nil assigns(:option)
    assert_template 'add_option'
  end

  test "should get options" do
    post :options, variable: { description: @variable.description, header: @variable.header, name: 'var_temp', display_name: 'Variable Temp', options: @variable.options, variable_type: @variable.variable_type }, format: 'js'
    assert_not_nil assigns(:variable)
    assert_template 'options'
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:variables)
  end

  test "should get paginated index" do
    get :index, format: 'js'
    assert_not_nil assigns(:variables)
    assert_template 'index'
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create variable" do
    assert_difference('Variable.count') do
      post :create, variable: { project_id: projects(:one).id, description: @variable.description, header: @variable.header, name: 'var_3', display_name: 'Variable Three', options: @variable.options, variable_type: @variable.variable_type }
    end

    assert_redirected_to variable_path(assigns(:variable))
  end

  test "should create dropdown variable" do
    assert_difference('Variable.count') do
      post :create, variable: { project_id: projects(:one).id, name: 'favorite_icecream', display_name: 'Favorite Icecream', variable_type: "dropdown",
                                option_tokens: {
                                  "1338308398442263" => { name: "Chocolate", value: "1", description: "" },
                                  "133830842117151" => { name: "Vanilla", value: "2", description: ""}
                                }
                              }
    end

    assert_not_nil assigns(:variable)
    assert_equal 2, assigns(:variable).options.size
    assert_redirected_to variable_path(assigns(:variable))
  end

  test "should not create variable without project" do
    assert_difference('Variable.count', 0) do
      post :create, variable: { project_id: nil, description: @variable.description, header: @variable.header, name: 'var_3', display_name: 'Variable Three', options: @variable.options, variable_type: @variable.variable_type }
    end

    assert_not_nil assigns(:variable)
    assert assigns(:variable).errors.size > 0
    assert_equal ["can't be blank"], assigns(:variable).errors[:project_id]
    assert_template 'new'
  end

  test "should create global variable for librarian" do
    login(users(:librarian))
    assert_difference('Variable.count', 1) do
      post :create, variable: { project_id: nil, description: @variable.description, header: @variable.header, name: 'global_variable', display_name: 'Global Variable', options: @variable.options, variable_type: @variable.variable_type }
    end

    assert_not_nil assigns(:variable)
    assert_redirected_to variable_path(assigns(:variable))
  end

  test "should show variable" do
    get :show, id: @variable
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @variable
    assert_response :success
  end

  test "should get edit for global variable for librarian" do
    login(users(:librarian))
    get :edit, id: variables(:global)
    assert_response :success
  end

  test "should update variable" do
    put :update, id: @variable, variable: { project_id: projects(:one).id, description: @variable.description, header: @variable.header, name: @variable.name, display_name: @variable.display_name, options: @variable.options, variable_type: @variable.variable_type }
    assert_redirected_to variable_path(assigns(:variable))
  end

  test "should update for global variable for librarian" do
    login(users(:librarian))
    put :update, id: variables(:global), variable: { project_id: nil, description: variables(:global).description, header: variables(:global).header, name: variables(:global).name, display_name: variables(:global).display_name, options: variables(:global).options, variable_type: variables(:global).variable_type }
    assert_redirected_to variable_path(assigns(:variable))
  end

  test "should update variable and change new option value for associated sheets" do
    assert_equal 3, variables(:change_options).sheet_variables.where(response: '1').size
    assert_equal 1, variables(:change_options).sheet_variables.where(response: '2').size
    assert_equal 2, variables(:change_options).sheet_variables.where(response: '3').size

    put :update, id: variables(:change_options), variable: {  project_id: variables(:change_options).project_id, description: variables(:change_options).description,
                                                              header: variables(:change_options).header, name: variables(:change_options).name, display_name: variables(:change_options).display_name,
                                                              variable_type: variables(:change_options).variable_type,
                                                              option_tokens: {
                                                                "133830842117151" => { name: "Option 1", value: "1", description: "Should have value 1", option_index: "0" },
                                                                "133830842117152" => { name: "Option 2", value: "2", description: "Should have value 2", option_index: "1" },
                                                                "133830842117154" => { name: "Option 3", value: "3", description: "Should have value 3", option_index: "2" },
                                                                "133830842117156" => { name: "Option 4", value: "4", description: "Should have value 4", option_index: "new" }
                                                              }
                                                            }

    assert_equal 1, assigns(:variable).sheet_variables.where(response: '1').size
    assert_equal 2, assigns(:variable).sheet_variables.where(response: '2').size
    assert_equal 3, assigns(:variable).sheet_variables.where(response: '3').size
    assert_redirected_to variable_path(assigns(:variable))
  end

  # Option 3 (value 1) being removed. Three sheets where the value existed are then reset to null.
  test "should update variable and remove option and reset option vallue for associated sheets" do
    assert_equal 3, variables(:change_options).sheet_variables.where(response: '1').size
    assert_equal 1, variables(:change_options).sheet_variables.where(response: '2').size
    assert_equal 2, variables(:change_options).sheet_variables.where(response: '3').size
    put :update, id: variables(:change_options), variable: {  project_id: variables(:change_options).project_id, description: variables(:change_options).description,
                                                              header: variables(:change_options).header, name: variables(:change_options).name, display_name: variables(:change_options).display_name,
                                                              variable_type: variables(:change_options).variable_type,
                                                              option_tokens: {
                                                                "133830842117151" => { name: "Option 1", value: "2", description: "Should have value 1", option_index: "0" },
                                                                "133830842117152" => { name: "Option 2", value: "3", description: "Should have value 2", option_index: "1" },
                                                                "133830842117156" => { name: "Option 4", value: "4", description: "Should have value 4", option_index: "new" }
                                                              }
                                                            }

    assert_equal 0, assigns(:variable).sheet_variables.where(response: '1').size
    assert_equal 1, assigns(:variable).sheet_variables.where(response: '2').size
    assert_equal 2, assigns(:variable).sheet_variables.where(response: '3').size
    assert_redirected_to variable_path(assigns(:variable))
  end

  test "should destroy variable" do
    assert_difference('Variable.current.count', -1) do
      delete :destroy, id: @variable
    end

    assert_redirected_to variables_path
  end

  test "should destroy global variable for librarian" do
    login(users(:librarian))
    assert_difference('Variable.current.count', -1) do
      delete :destroy, id: variables(:global)
    end

    assert_redirected_to variables_path
  end
end
