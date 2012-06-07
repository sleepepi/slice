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
    post :add_option, variable: { description: @variable.description, header: @variable.header, name: 'Variable Temp', response: @variable.response, options: @variable.options, variable_type: @variable.variable_type }, format: 'js'
    assert_not_nil assigns(:variable)
    assert_not_nil assigns(:option)
    assert_template 'add_option'
  end

  test "should get options" do
    post :options, variable: { description: @variable.description, header: @variable.header, name: 'Variable Temp', response: @variable.response, options: @variable.options, variable_type: @variable.variable_type }, format: 'js'
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
      post :create, variable: { description: @variable.description, header: @variable.header, name: 'Variable Three', response: @variable.response, options: @variable.options, variable_type: @variable.variable_type }
    end

    assert_redirected_to variable_path(assigns(:variable))
  end

  test "should create dropdown variable" do
    assert_difference('Variable.count') do
      post :create, variable: { name: 'Favorite Icecream', variable_type: "dropdown",
                                option_tokens: {
                                  "1338308398442263" => { "name" => "Chocolate", "value" => "1", "description" => "" },
                                  "133830842117151" => { "name" => "Vanilla", "value" => "2", "description" => ""}
                                }
                              }
    end

    assert_not_nil assigns(:variable)
    assert_equal 2, assigns(:variable).options.size
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

  test "should update variable" do
    put :update, id: @variable, variable: { description: @variable.description, header: @variable.header, name: @variable.name, response: @variable.response, options: @variable.options, variable_type: @variable.variable_type }
    assert_redirected_to variable_path(assigns(:variable))
  end

  test "should destroy variable" do
    assert_difference('Variable.current.count', -1) do
      delete :destroy, id: @variable
    end

    assert_redirected_to variables_path
  end
end
