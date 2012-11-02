require 'test_helper'

class DomainsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @domain = domains(:one)
  end

  test "should get index" do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:domains)
  end

  test "should get new" do
    get :new, project_id: @project
    assert_response :success
  end

  test "should create domain" do
    assert_difference('Domain.count') do
      post :create, project_id: @project, domain: { name: 'New Domain',
                                                    option_tokens: {
                                                      "1338308398442263" => { name: "Chocolate", value: "1", description: "", color: '#FFBBCC' },
                                                      "133830842117151" => { name: "Vanilla", value: "2", description: "", color: '#FFAAFF' } } }
    end

    assert_redirected_to project_domain_path(assigns(:domain).project, assigns(:domain))
  end

  test "should not create domain where options have non-unique values" do
    assert_difference('Domain.count', 0) do
      post :create, project_id: @project, domain: { name: 'New Domain', description: @domain.description,
                                                    option_tokens: {
                                                      "1338308398442263" => { name: "Chocolate", value: "1", description: "" },
                                                      "133830842117151" => { name: "Vanilla", value: "1", description: ""} } }
    end

    assert_not_nil assigns(:domain)
    assert assigns(:domain).errors.size > 0
    assert_equal ["values must be unique"], assigns(:domain).errors[:option]
    assert_template 'new'
  end

  test "should not create domain where options have colons as part of the value" do
    assert_difference('Domain.count', 0) do
      post :create, project_id: @project, domain: { name: 'New Domain', description: @domain.description,
                                option_tokens: {
                                  "1338308398442263" => { name: "Chocolate", value: "1-chocolate", description: "" },
                                  "133830842117151" => { name: "Vanilla", value: "2:vanilla", description: ""} } }
    end

    assert_not_nil assigns(:domain)
    assert assigns(:domain).errors.size > 0
    assert_equal ["values can't contain colons"], assigns(:domain).errors[:option]
    assert_template 'new'
  end

  test "should not create domain where options have blank value" do
    assert_difference('Domain.count', 0) do
      post :create, project_id: @project, domain: { name: 'New Domain', description: @domain.description,
                                                    option_tokens: {
                                                      "1338308398442263" => { name: "Chocolate", value: "", description: "" } } }
    end

    assert_not_nil assigns(:domain)
    assert assigns(:domain).errors.size > 0
    assert_equal ["values can't be blank"], assigns(:domain).errors[:option]
    assert_template 'new'
  end

  test "should show domain" do
    get :show, id: @domain, project_id: @project
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @domain, project_id: @project
    assert_response :success
  end

  test "should update domain" do
    put :update, id: @domain, project_id: @project, domain: { name: @domain.name,
                                                              option_tokens: {
                                                                "1338308398442263" => { name: "Chocolate", value: "1", description: "", color: '#FFBBCC' },
                                                                "133830842117151" => { name: "Vanilla", value: "2", description: "", color: '#FFAAFF' } } }
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
                    option_tokens: {
                      "133830842117151" => { name: "Option 1", value: "1", description: "Should have value 1", option_index: "0" },
                      "133830842117152" => { name: "Option 2", value: "2", description: "Should have value 2", option_index: "1" },
                      "133830842117154" => { name: "Option 3", value: "3", description: "Should have value 3", option_index: "2" },
                      "133830842117156" => { name: "Option 4", value: "4", description: "Should have value 4", option_index: "new" }
                    }
                  }

    assert_equal 1, assigns(:domain).sheet_variables.where(response: '1').size
    assert_equal 2, assigns(:domain).sheet_variables.where(response: '2').size
    assert_equal 3, assigns(:domain).sheet_variables.where(response: '3').size
    assert_equal 1, assigns(:domain).grids.where(response: '1').size
    assert_equal 2, assigns(:domain).grids.where(response: '2').size
    assert_equal 3, assigns(:domain).grids.where(response: '3').size
    assert_redirected_to project_domain_path(assigns(:domain).project, assigns(:domain))
  end

  test "should destroy domain" do
    assert_difference('Domain.current.count', -1) do
      delete :destroy, id: @domain, project_id: @project
    end

    assert_redirected_to project_domains_path
  end
end
