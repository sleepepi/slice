# frozen_string_literal: true

require "test_helper"

# Tests to assure project editors can view and modify variables.
class VariablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_editor = users(:project_one_editor)
    @site_editor = users(:site_one_editor)
    @site_viewer = users(:site_one_viewer)

    @project = projects(:one)
    @variable = variables(:one)
  end

  test "should get copy" do
    login(@project_editor)
    get copy_project_variable_url(@project, @variable)
    assert_template "new"
    assert_response :success
  end

  test "should get copy for grid variables" do
    login(@project_editor)
    get copy_project_variable_url(@project, variables(:grid))
    assert_template "new"
    assert_response :success
  end

  test "should not copy invalid variable" do
    login(@project_editor)
    get copy_project_variable_url(@project, -1)
    assert_redirected_to project_variables_url(@project)
  end

  test "should not copy variable with invalid project" do
    login(@project_editor)
    get copy_project_variable_url(-1, @variable)
    assert_redirected_to root_url
  end

  test "should add grid variable" do
    login(@project_editor)
    post add_grid_variable_project_variables_url(@project, format: "js")
    assert_template "add_grid_variable"
    assert_response :success
  end

  test "should get index" do
    login(@project_editor)
    get project_variables_url(@project)
    assert_response :success
  end

  test "should not get index with invalid project" do
    login(@project_editor)
    get project_variables_url(-1)
    assert_redirected_to root_url
  end

  test "should get new" do
    login(@project_editor)
    get new_project_variable_url(@project)
    assert_response :success
  end

  test "should not get new variable with invalid project" do
    login(@project_editor)
    get new_project_variable_url(-1)
    assert_redirected_to root_url
  end

  test "should create variable" do
    login(@project_editor)
    assert_difference("Variable.count") do
      post project_variables_url(@project), params: {
        variable: {
          description: @variable.description, name: "var_3",
          display_name: "Variable Three", variable_type: @variable.variable_type
        }
      }
    end
    assert_redirected_to project_variable_url(assigns(:variable).project, assigns(:variable))
  end

  test "should create dropdown variable" do
    login(@project_editor)
    assert_difference("Variable.count") do
      post project_variables_url(@project), params: {
        variable: {
          name: "favorite_icecream", display_name: "Favorite Icecream",
          variable_type: "dropdown", domain_id: domains(:icecream_flavors).id
        }
      }
    end
    assert_equal 2, assigns(:variable).domain_options.count
    assert_redirected_to project_variable_url(assigns(:variable).project, assigns(:variable))
  end

  test "should create string variable without a domain" do
    login(@project_editor)
    assert_difference("Variable.count") do
      post project_variables_url(@project), params: {
        variable: {
          name: "restaurant", display_name: "Favorite Restaurant",
          variable_type: "string", domain_id: domains(:icecream_flavors).id
        }
      }
    end
    assert_equal 0, assigns(:variable).domain_options.count
    assert_nil assigns(:variable).domain
    assert_redirected_to project_variable_url(assigns(:variable).project, assigns(:variable))
  end

  test "should not create variable with invalid project" do
    login(@project_editor)
    assert_difference("Variable.count", 0) do
      post project_variables_url(-1), params: {
        variable: {
          description: @variable.description, name: "var_3",
          display_name: "Variable Three", variable_type: @variable.variable_type
        }
      }
    end
    assert_redirected_to root_url
  end

  test "should create grid variable and combine non-unique child variables" do
    login(@project_editor)
    assert_difference("Variable.count") do
      post project_variables_url(@project), params: {
        variable: {
          description: @variable.description,
          name: "var_grid_tmp",
          display_name: "Variable Grid",
          variable_type: "grid",
          grid_tokens: [
            { variable_id: ActiveRecord::FixtureSet.identify(:integer) },
            { variable_id: ActiveRecord::FixtureSet.identify(:integer) }
          ]
        }
      }
    end
    assert 1, assigns(:variable).child_variables.count
    assert_redirected_to [@project, Variable.last]
  end

  test "should show variable" do
    login(@project_editor)
    get project_variable_url(@project, @variable)
    assert_response :success
  end

  test "should show scale variable" do
    login(@project_editor)
    get project_variable_url(@project, variables(:change_domain_options))
    assert_response :success
  end

  test "should not show variable with invalid project" do
    login(@project_editor)
    get project_variable_url(-1, @variable)
    assert_redirected_to root_url
  end

  test "should show variable for project with no sites" do
    login(users(:regular))
    get project_variable_url(projects(:no_sites), variables(:no_sites))
    assert_response :success
  end

  test "should not show invalid variable" do
    login(@project_editor)
    get project_variable_url(@project, -1)
    assert_redirected_to project_variables_url(@project)
  end

  test "should get edit" do
    login(@project_editor)
    get edit_project_variable_url(@project, @variable)
    assert_response :success
  end

  test "should not get edit for invalid variable" do
    login(@project_editor)
    get edit_project_variable_url(@project, -1)
    assert_redirected_to project_variables_url(@project)
  end

  test "should not get edit with invalid project" do
    login(@project_editor)
    get edit_project_variable_url(-1, @variable)
    assert_redirected_to root_url
  end

  test "should not get edit for site user" do
    login(@site_editor)
    get edit_project_variable_url(@project, @variable)
    assert_redirected_to root_url
  end

  test "should update variable" do
    login(@project_editor)
    patch project_variable_url(@project, @variable), params: {
      variable: {
        description: @variable.description, name: @variable.name,
        display_name: @variable.display_name
      }
    }
    assert_redirected_to project_variable_url(assigns(:variable).project, assigns(:variable))
  end

  test "should not update variable with blank display name" do
    login(@project_editor)
    patch project_variable_url(@project, @variable), params: {
      variable: {
        description: @variable.description, name: @variable.name,
        display_name: "", variable_type: @variable.variable_type
      }
    }
    assert_equal ["can't be blank"], assigns(:variable).errors[:display_name]
    assert_template "edit"
  end

  test "should not update invalid variable" do
    login(@project_editor)
    patch project_variable_url(@project, -1), params: {
      variable: {
        description: @variable.description, name: @variable.name,
        display_name: @variable.display_name, variable_type: @variable.variable_type
      }
    }
    assert_redirected_to project_variables_url(@project)
  end

  test "should not update variable with invalid project" do
    login(@project_editor)
    patch project_variable_url(-1, @variable), params: {
      variable: {
        description: @variable.description, name: @variable.name,
        display_name: @variable.display_name, variable_type: @variable.variable_type
      }
    }
    assert_redirected_to root_url
  end

  test "should update variable and switch domain single choice" do
    login(@project_editor)
    patch project_variable_url(@project, variables(:data_captured)), params: {
      variable: { domain_id: domains(:three_restaurants).id }
    }
    assert_equal domains(:three_restaurants), assigns(:variable).domain
    assert_redirected_to project_variable_url(assigns(:variable).project, assigns(:variable))
  end

  test "should update variable and switch domain for numerics" do
    login(@project_editor)
    patch project_variable_url(@project, variables(:data_captured)), params: {
      variable: {
        domain_id: domains(:one_restaurant_not_encompassing).id,
        variable_type: "integer"
      }
    }
    assert_equal "integer", assigns(:variable).variable_type
    assert_equal domains(:one_restaurant_not_encompassing), assigns(:variable).domain
    assert_redirected_to project_variable_url(assigns(:variable).project, assigns(:variable))
  end

  test "should update variable and switch domain for checkbox" do
    login(@project_editor)
    patch project_variable_url(@project, variables(:checkbox)), params: {
      variable: { domain_id: domains(:one).id }
    }
    assert_equal domains(:one), assigns(:variable).domain
    assert_redirected_to project_variable_url(@project, variables(:checkbox))
  end

  test "should update variable and remove domain from sheet variables" do
    login(@project_editor)
    assert_difference("SheetVariable.where(value: [1,2]).count", 1) do
      patch project_variable_url(@project, variables(:data_captured)), params: {
        variable: { domain_id: nil }
      }
    end
    assert_nil assigns(:variable).domain
    assert_redirected_to project_variable_url(@project, variables(:data_captured))
  end

  test "should update variable and remove domain from responses" do
    login(@project_editor)
    assert_difference("Response.where(value: %w(acct101 econ101 math123 phys500 biol327)).count", 5) do
      patch project_variable_url(@project, variables(:checkbox)), params: {
        variable: { domain_id: nil }
      }
    end
    assert_nil assigns(:variable).domain
    assert_redirected_to project_variable_url(@project, variables(:checkbox))
  end

  test "should update variable and remove domain from grids" do
    login(@project_editor)
    assert_difference("Grid.where(value: [1, 2, 3]).count", 6) do
      patch project_variable_url(@project, variables(:change_domain_options)), params: {
        variable: { domain_id: nil }
      }
    end
    assert_nil assigns(:variable).domain
    assert_redirected_to project_variable_url(@project, variables(:change_domain_options))
  end

  # Removing "grid_change_options" variable from grid.
  test "should update variable and remove first child variable from grid" do
    login(@project_editor)
    assert_difference("GridVariable.count", -1) do
      patch project_variable_url(@project, variables(:grid)), params: {
        variable: {
          name: "grid",
          display_name: "Grid of Variables",
          description: "Testing for grid of Variables",
          variable_type: "grid",
          grid_tokens: [
            { variable_id: ActiveRecord::FixtureSet.identify(:checkbox) },
            { variable_id: ActiveRecord::FixtureSet.identify(:height) },
            { variable_id: ActiveRecord::FixtureSet.identify(:weight) },
            { variable_id: ActiveRecord::FixtureSet.identify(:calculated) },
            { variable_id: ActiveRecord::FixtureSet.identify(:integer) },
            { variable_id: ActiveRecord::FixtureSet.identify(:time_of_day) }
          ]
        }
      }
    end
    assert_equal 6, assigns(:variable).child_grid_variables.count
    assert_redirected_to project_variable_url(@project, variables(:grid))
  end

  test "should destroy variable" do
    login(@project_editor)
    assert_difference("Variable.current.count", -1) do
      delete project_variable_url(@project, @variable)
    end
    assert_redirected_to project_variables_url(assigns(:project))
  end

  test "should not destroy variable with invalid project" do
    login(@project_editor)
    assert_difference("Variable.current.count", 0) do
      delete project_variable_url(-1, @variable)
    end
    assert_redirected_to root_url
  end

  test "should restore deleted variable" do
    login(@project_editor)
    assert_difference("Variable.current.count") do
      post restore_project_variable_url(@project, variables(:deleted))
    end
    assert_redirected_to [@project, variables(:deleted)]
  end

  test "should get search" do
    login(@project_editor)
    get search_project_variables_url(@project, format: "js"), params: { q: "var" }, xhr: true
    assert_response :success
  end
end
