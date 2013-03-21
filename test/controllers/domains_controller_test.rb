require 'test_helper'

class DomainsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @domain = domains(:one)
  end

  test "should show values" do
    post :values, project_id: @project, domain_id: @domain, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:domain)
    assert_template 'values'
  end

  test "should add option" do
    post :add_option, project_id: @project, format: 'js'
    assert_template 'add_option'
  end

  test "should get index" do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:domains)
  end

  test "should not get index with invalid project" do
    get :index, project_id: -1
    assert_nil assigns(:domains)
    assert_redirected_to root_path
  end

  test "should get new" do
    get :new, project_id: @project
    assert_response :success
  end

  test "should create domain" do
    assert_difference('Domain.count') do
      post :create, project_id: @project, domain: { name: 'new_domain',
                                                    option_tokens: [
                                                      { name: "Chocolate", value: "1", description: "", color: '#FFBBCC' },
                                                      { name: "Vanilla", value: "2", description: "", color: '#FFAAFF' } ] }
    end

    assert_redirected_to project_domain_path(assigns(:domain).project, assigns(:domain))
  end

  test "should not create domain where options have non-unique values" do
    assert_difference('Domain.count', 0) do
      post :create, project_id: @project, domain: { name: 'new_domain', description: @domain.description,
                                                    option_tokens: [
                                                      { name: "Chocolate", value: "1", description: "" },
                                                      { name: "Vanilla", value: "1", description: ""} ] }
    end

    assert_not_nil assigns(:domain)
    assert assigns(:domain).errors.size > 0
    assert_equal ["values must be unique"], assigns(:domain).errors[:option]
    assert_template 'new'
  end

  test "should not create domain where options have colons as part of the value" do
    assert_difference('Domain.count', 0) do
      post :create, project_id: @project, domain: { name: 'new_domain', description: @domain.description,
                                option_tokens: [
                                  { name: "Chocolate", value: "1-chocolate", description: "" },
                                  { name: "Vanilla", value: "2:vanilla", description: "" } ] }
    end

    assert_not_nil assigns(:domain)
    assert assigns(:domain).errors.size > 0
    assert_equal ["values can't contain colons"], assigns(:domain).errors[:option]
    assert_template 'new'
  end

  test "should not create domain where options have blank value" do
    assert_difference('Domain.count', 0) do
      post :create, project_id: @project, domain: { name: 'new_domain', description: @domain.description,
                                                    option_tokens: [ { name: "Chocolate", value: "", description: "" } ] }
    end

    assert_not_nil assigns(:domain)
    assert assigns(:domain).errors.size > 0
    assert_equal ["values can't be blank"], assigns(:domain).errors[:option]
    assert_template 'new'
  end

  test "should not create domain with blank name" do
    assert_difference('Domain.count', 0) do
      post :create, project_id: @project, domain: { name: '', option_tokens: [ { name: "Chocolate", value: "1", description: "", color: '#FFBBCC' }, { name: "Vanilla", value: "2", description: "", color: '#FFAAFF' } ] }
    end

    assert_not_nil assigns(:domain)
    assert assigns(:domain).errors.size > 0
    assert_equal ["can't be blank", "is invalid"], assigns(:domain).errors[:name]
    assert_template 'new'
  end

  test "should not create document with invalid project" do
    assert_difference('Domain.count', 0) do
      post :create, project_id: -1, domain: { name: 'new_domain', option_tokens: [ { name: "Chocolate", value: "1", description: "", color: '#FFBBCC' }, { name: "Vanilla", value: "2", description: "", color: '#FFAAFF' } ] }
    end

    assert_nil assigns(:domain)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end

  test "should show domain" do
    get :show, id: @domain, project_id: @project
    assert_not_nil assigns(:domain)
    assert_response :success
  end

  test "should not show domain with invalid project" do
    get :show, id: @domain, project_id: -1
    assert_nil assigns(:domain)
    assert_redirected_to root_path
  end

  test "should get edit" do
    get :edit, id: @domain, project_id: @project
    assert_not_nil assigns(:domain)
    assert_response :success
  end

  test "should not get edit with invalid project" do
    get :edit, id: @domain, project_id: -1
    assert_nil assigns(:domain)
    assert_redirected_to root_path
  end

  test "should update domain" do
    put :update, id: @domain, project_id: @project, domain: { name: @domain.name,
                                                              option_tokens: [
                                                                { name: "Chocolate", value: "1", description: "", color: '#FFBBCC' },
                                                                { name: "Vanilla", value: "2", description: "", color: '#FFAAFF' } ] }
    assert_redirected_to project_domain_path(assigns(:domain).project, assigns(:domain))
  end

  test "should update domain and change new option value for associated sheets and grids" do
    assert_equal 3, domains(:change_options).sheet_variables.where(response: '1').size
    assert_equal 1, domains(:change_options).sheet_variables.where(response: '2').size
    assert_equal 2, domains(:change_options).sheet_variables.where(response: '3').size
    assert_equal 3, domains(:change_options).grids.where(response: '1').size
    assert_equal 1, domains(:change_options).grids.where(response: '2').size
    assert_equal 2, domains(:change_options).grids.where(response: '3').size

    put :update, id: domains(:change_options), project_id: @project,
                 domain: {
                    name: domains(:change_options).name,
                    description: domains(:change_options).description,
                    option_tokens: [
                      { name: "Option 1", value: "1", description: "Should have value 1", option_index: "0" },
                      { name: "Option 2", value: "2", description: "Should have value 2", option_index: "1" },
                      { name: "Option 3", value: "3", description: "Should have value 3", option_index: "2" },
                      { name: "Option 4", value: "4", description: "Should have value 4", option_index: "new" }
                    ]
                 }

    assert_equal 1, assigns(:domain).sheet_variables.where(response: '1').size
    assert_equal 2, assigns(:domain).sheet_variables.where(response: '2').size
    assert_equal 3, assigns(:domain).sheet_variables.where(response: '3').size
    assert_equal 1, assigns(:domain).grids.where(response: '1').size
    assert_equal 2, assigns(:domain).grids.where(response: '2').size
    assert_equal 3, assigns(:domain).grids.where(response: '3').size
    assert_redirected_to project_domain_path(assigns(:domain).project, assigns(:domain))
  end

  # Option 3 (value 1) being removed. Three sheets where the value existed are then reset to null.
  test "should update domain and remove option and reset option value for associated sheets and grids" do
    assert_equal 3, domains(:change_options).sheet_variables.where(response: '1').size
    assert_equal 1, domains(:change_options).sheet_variables.where(response: '2').size
    assert_equal 2, domains(:change_options).sheet_variables.where(response: '3').size
    assert_equal 3, domains(:change_options).grids.where(response: '1').size
    assert_equal 1, domains(:change_options).grids.where(response: '2').size
    assert_equal 2, domains(:change_options).grids.where(response: '3').size
    put :update, id: domains(:change_options), project_id: @project,
                 domain: {
                    name: domains(:change_options).name,
                    description: domains(:change_options).description,
                    option_tokens: [
                      { name: "Option 1", value: "2", description: "Should have value 1", option_index: "0" },
                      { name: "Option 2", value: "3", description: "Should have value 2", option_index: "1" },
                      { name: "Option 4", value: "4", description: "Should have value 4", option_index: "new" }
                    ]
                 }

    assert_equal 0, assigns(:domain).sheet_variables.where(response: '1').size
    assert_equal 1, assigns(:domain).sheet_variables.where(response: '2').size
    assert_equal 2, assigns(:domain).sheet_variables.where(response: '3').size
    assert_equal 0, assigns(:domain).grids.where(response: '1').size
    assert_equal 1, assigns(:domain).grids.where(response: '2').size
    assert_equal 2, assigns(:domain).grids.where(response: '3').size
    assert_redirected_to project_domain_path(assigns(:domain).project, assigns(:domain))
  end

  test "should not update domain and not change existing values for associated sheets and grids if validation fails" do
    assert_equal 3, domains(:change_options).sheet_variables.where(response: '1').size
    assert_equal 1, domains(:change_options).sheet_variables.where(response: '2').size
    assert_equal 2, domains(:change_options).sheet_variables.where(response: '3').size
    assert_equal 3, domains(:change_options).grids.where(response: '1').size
    assert_equal 1, domains(:change_options).grids.where(response: '2').size
    assert_equal 2, domains(:change_options).grids.where(response: '3').size

    put :update, id: domains(:change_options), project_id: @project,
                 domain: {
                    name: domains(:change_options).name,
                    description: domains(:change_options).description,
                    option_tokens: [
                        { name: "Option 1", value: "1", description: "Should have value 1", option_index: "0" },
                        { name: "Option 2", value: "2", description: "Should have value 2", option_index: "1" },
                        { name: "Option 3", value: "3", description: "Should have value 3", option_index: "2" },
                        { name: "Option 4", value: ":4", description: "Should have value 4", option_index: "new" }
                      ]
                    }

    assert_equal 3, variables(:change_options).sheet_variables.where(response: '1').size
    assert_equal 1, variables(:change_options).sheet_variables.where(response: '2').size
    assert_equal 2, variables(:change_options).sheet_variables.where(response: '3').size
    assert_equal 3, domains(:change_options).grids.where(response: '1').size
    assert_equal 1, domains(:change_options).grids.where(response: '2').size
    assert_equal 2, domains(:change_options).grids.where(response: '3').size

    assert_not_nil assigns(:domain)
    assert assigns(:domain).errors.size > 0
    assert_equal ["values can't contain colons"], assigns(:domain).errors[:option]
    assert_template 'edit'
  end

  test "should not update domain with blank name" do
    put :update, id: @domain, project_id: @project, domain: { name: '', option_tokens: [ { name: "Chocolate", value: "1", description: "", color: '#FFBBCC' }, { name: "Vanilla", value: "2", description: "", color: '#FFAAFF' } ] }

    assert_not_nil assigns(:domain)
    assert assigns(:domain).errors.size > 0
    assert_equal ["can't be blank", "is invalid"], assigns(:domain).errors[:name]
    assert_template 'edit'
  end

  test "should not update domain with invalid project" do
    put :update, id: @domain, project_id: -1, domain: { name: @domain.name, option_tokens: [ { name: "Chocolate", value: "1", description: "", color: '#FFBBCC' }, { name: "Vanilla", value: "2", description: "", color: '#FFAAFF' } ] }

    assert_nil assigns(:domain)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end

  test "should destroy domain" do
    assert_difference('Domain.current.count', -1) do
      delete :destroy, id: @domain, project_id: @project
    end

    assert_not_nil assigns(:domain)
    assert_not_nil assigns(:project)

    assert_redirected_to project_domains_path
  end

  test "should not destroy domain with invalid project" do
    assert_difference('Domain.current.count', 0) do
      delete :destroy, id: @domain, project_id: -1
    end

    assert_nil assigns(:domain)
    assert_nil assigns(:project)

    assert_redirected_to root_path
  end
end
