# frozen_string_literal: true

require "test_helper"

# Tests to make sure that domains can be created by project editors.
class DomainsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @domain = domains(:one)
  end

  test "should show values" do
    post :values, params: {
      project_id: @project, domain_id: @domain
    }, format: "js"
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:domain)
    assert_template "values"
  end

  test "should add option" do
    post :add_option, params: { project_id: @project }, format: "js"
    assert_template "add_option"
  end

  test "should get index" do
    get :index, params: { project_id: @project }
    assert_response :success
    assert_not_nil assigns(:domains)
  end

  test "should not get index with invalid project" do
    get :index, params: { project_id: -1 }
    assert_nil assigns(:domains)
    assert_redirected_to root_path
  end

  test "should get new" do
    get :new, params: { project_id: @project }
    assert_response :success
  end

  test "should create domain" do
    assert_difference("DomainOption.count", 2) do
      assert_difference("Domain.count") do
        post :create, params: {
          project_id: @project,
          domain: {
            name: "new_domain", display_name: "New Domain",
            option_tokens: [
              { name: "Chocolate", value: "1", description: "" },
              { name: "Vanilla", value: "2", description: "" }
            ]
          }
        }
      end
    end
    assert_redirected_to project_domain_path(assigns(:domain).project, assigns(:domain))
  end

  test "should create domain and continue" do
    assert_difference("Domain.count") do
      post :create, params: {
        project_id: @project, continue: "1",
        domain: {
          name: "new_domain_2", display_name: "New Domain Two",
          option_tokens: [
            { name: "Chocolate", value: "1", description: "" },
            { name: "Vanilla", value: "2", description: "" }
          ]
        }
      }
    end
    assert_redirected_to new_project_domain_path(assigns(:domain).project)
  end

  test "should create domain where options have default values" do
    assert_difference("Domain.count") do
      post :create, params: {
        project_id: @project,
        domain: {
          name: "new_domain",
          display_name: "New Domain",
          description: @domain.description,
          option_tokens: [{ name: "Chocolate", value: "", description: "" }]
        }
      }
    end
    assert_not_nil assigns(:domain)
    assert_equal "Chocolate", assigns(:domain).domain_options.first.name
    assert_equal "1", assigns(:domain).domain_options.first.value
    assert_redirected_to project_domain_path(assigns(:domain).project, assigns(:domain))
  end

  test "should not create domain with blank name" do
    assert_difference("Domain.count", 0) do
      post :create, params: {
        project_id: @project,
        domain: {
          name: "",
          display_name: "",
          option_tokens: [
            { name: "Chocolate", value: "1", description: "" },
            { name: "Vanilla", value: "2", description: "" }
          ]
        }
      }
    end
    assert_not_nil assigns(:domain)
    assert_equal ["can't be blank", "is invalid"], assigns(:domain).errors[:name]
    assert_template "new"
  end

  test "should not create document with invalid project" do
    assert_difference("Domain.count", 0) do
      post :create, params: {
        project_id: -1,
        domain: {
          name: "new_domain",
          display_name: "New Domain",
          option_tokens: [
            { name: "Chocolate", value: "1", description: "" },
            { name: "Vanilla", value: "2", description: "" }
          ]
        }
      }
    end
    assert_nil assigns(:domain)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end

  test "should show domain" do
    get :show, params: { project_id: @project, id: @domain }
    assert_not_nil assigns(:domain)
    assert_response :success
  end

  test "should not show domain with invalid project" do
    get :show, params: { project_id: -1, id: @domain }
    assert_nil assigns(:domain)
    assert_redirected_to root_path
  end

  test "should get edit" do
    get :edit, params: { project_id: @project, id: @domain }
    assert_not_nil assigns(:domain)
    assert_response :success
  end

  test "should not get edit with invalid project" do
    get :edit, params: { id: @domain, project_id: -1 }
    assert_nil assigns(:domain)
    assert_redirected_to root_path
  end

  test "should update domain" do
    patch :update, params: {
      project_id: @project, id: @domain,
      domain: {
        name: @domain.name, display_name: @domain.display_name,
        option_tokens: [
          { name: "Chocolate", value: "1", description: "", domain_option_id: domain_options(:one_easy).id },
          { name: "Vanilla", value: "2", description: "", domain_option_id: domain_options(:one_medium).id }
        ]
      }
    }
    # TODO CHECK THAT domain_options(:one_hard) no longer exists.
    assert_redirected_to project_domain_path(assigns(:domain).project, assigns(:domain))
  end

  test "should update domain and continue" do
    patch :update, params: {
      project_id: @project, id: @domain, continue: "1",
      domain: {
        name: @domain.name,
        display_name: @domain.display_name,
        option_tokens: [
          { name: "Chocolate", value: "1", description: "", domain_option_id: domain_options(:one_easy).id },
          { name: "Vanilla", value: "2", description: "", domain_option_id: domain_options(:one_medium).id }
        ]
      }
    }
    assert_redirected_to new_project_domain_path(assigns(:domain).project)
  end

  test "should not update domain with blank name" do
    patch :update, params: {
      project_id: @project, id: @domain,
      domain: {
        name: "",
        display_name: "",
        option_tokens: [
          { name: "Chocolate", value: "1", description: "", domain_option_id: domain_options(:one_easy).id },
          { name: "Vanilla", value: "2", description: "", domain_option_id: domain_options(:one_medium).id }
        ]
      }
    }
    assert_not_nil assigns(:domain)
    assert_equal ["can't be blank", "is invalid"], assigns(:domain).errors[:name]
    assert_template "edit"
  end

  test "should not update domain with invalid project" do
    patch :update, params: {
      project_id: -1, id: @domain,
      domain: {
        name: @domain.name,
        display_name: @domain.display_name,
        option_tokens: [
          { name: "Chocolate", value: "1", description: "", domain_option_id: domain_options(:one_easy).id },
          { name: "Vanilla", value: "2", description: "", domain_option_id: domain_options(:one_medium).id }
        ]
      }
    }
    assert_nil assigns(:domain)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end

  test "should destroy domain" do
    assert_difference("Domain.current.count", -1) do
      delete :destroy, params: { project_id: @project, id: @domain }
    end
    assert_not_nil assigns(:domain)
    assert_not_nil assigns(:project)
    assert_redirected_to project_domains_path
  end

  test "should not destroy domain with invalid project" do
    assert_difference("Domain.current.count", 0) do
      delete :destroy, params: { project_id: -1, id: @domain }
    end
    assert_nil assigns(:domain)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end
end
