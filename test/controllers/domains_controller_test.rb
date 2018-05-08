# frozen_string_literal: true

require "test_helper"

# Tests to make sure that domains can be created by project editors.
class DomainsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_editor = users(:valid)
    @project = projects(:one)
    @domain = domains(:one)
  end

  def domain_params
    {
      name: "new_domain", display_name: "New Domain",
      option_tokens: [
        { name: "Chocolate", value: "1", description: "" },
        { name: "Vanilla", value: "2", description: "" }
      ]
    }
  end

  test "should show values" do
    login(@project_editor)
    post values_project_domains_url(@project, format: "js"), params: {
      domain_id: @domain.id
    }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:domain)
    assert_template "values"
  end

  test "should add option" do
    login(@project_editor)
    post add_option_project_domains_url(@project, format: "js")
    assert_template "add_option"
  end

  test "should get index" do
    login(@project_editor)
    get project_domains_url(@project)
    assert_response :success
    assert_not_nil assigns(:domains)
  end

  test "should not get index with invalid project" do
    login(@project_editor)
    get project_domains_url(-1)
    assert_nil assigns(:domains)
    assert_redirected_to root_url
  end

  test "should get new" do
    login(@project_editor)
    get new_project_domain_url(@project)
    assert_response :success
  end

  test "should create domain" do
    login(@project_editor)
    assert_difference("DomainOption.count", 2) do
      assert_difference("Domain.count") do
        post project_domains_url(@project), params: {
          domain: domain_params
        }
      end
    end
    assert_redirected_to project_domain_url(assigns(:domain).project, assigns(:domain))
  end

  test "should create domain and continue" do
    login(@project_editor)
    assert_difference("Domain.count") do
      post project_domains_url(@project), params: {
        domain: domain_params,
        continue: "1"
      }
    end
    assert_redirected_to new_project_domain_url(assigns(:domain).project)
  end

  test "should create domain where options have default values" do
    login(@project_editor)
    assert_difference("Domain.count") do
      post project_domains_url(@project), params: {
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
    assert_redirected_to project_domain_url(assigns(:domain).project, assigns(:domain))
  end

  test "should not create domain with blank name" do
    login(@project_editor)
    assert_difference("Domain.count", 0) do
      post project_domains_url(@project), params: {
        domain: domain_params.merge(name: "", display_name: "")
      }
    end
    assert_not_nil assigns(:domain)
    assert_equal ["can't be blank", "is invalid"], assigns(:domain).errors[:name]
    assert_template "new"
  end

  test "should not create document with invalid project" do
    login(@project_editor)
    assert_difference("Domain.count", 0) do
      post project_domains_url(-1), params: {
        domain: domain_params
      }
    end
    assert_nil assigns(:domain)
    assert_nil assigns(:project)
    assert_redirected_to root_url
  end

  test "should show domain" do
    login(@project_editor)
    get project_domain_url(@project, @domain)
    assert_not_nil assigns(:domain)
    assert_response :success
  end

  test "should not show domain with invalid project" do
    login(@project_editor)
    get project_domain_url(-1, @domain)
    assert_nil assigns(:domain)
    assert_redirected_to root_url
  end

  test "should get edit" do
    login(@project_editor)
    get edit_project_domain_url(@project, @domain)
    assert_not_nil assigns(:domain)
    assert_response :success
  end

  test "should not get edit with invalid project" do
    login(@project_editor)
    get edit_project_domain_url(-1, @domain)
    assert_nil assigns(:domain)
    assert_redirected_to root_url
  end

  test "should update domain" do
    login(@project_editor)
    assert_difference("DomainOption.count", -1) do
      patch project_domain_url(@project, @domain), params: {
        domain: {
          name: @domain.name,
          display_name: @domain.display_name,
          option_tokens: [
            { name: "Chocolate", value: "1", description: "", domain_option_id: domain_options(:one_easy).id },
            { name: "Vanilla", value: "2", description: "", domain_option_id: domain_options(:one_medium).id }
          ]
        }
      }
    end
    assert_redirected_to project_domain_url(@project, @domain)
  end

  test "should update domain and continue" do
    login(@project_editor)
    patch project_domain_url(@project, @domain), params: {
      domain: {
        name: @domain.name,
        display_name: @domain.display_name,
        option_tokens: [
          { name: "Chocolate", value: "1", description: "", domain_option_id: domain_options(:one_easy).id },
          { name: "Vanilla", value: "2", description: "", domain_option_id: domain_options(:one_medium).id }
        ]
      },
      continue: "1"
    }
    assert_redirected_to new_project_domain_url(assigns(:domain).project)
  end

  test "should not update domain with blank name" do
    login(@project_editor)
    patch project_domain_url(@project, @domain), params: {
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
    login(@project_editor)
    patch project_domain_url(-1, @domain), params: {
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
    assert_redirected_to root_url
  end

  test "should destroy domain" do
    login(@project_editor)
    assert_difference("Domain.current.count", -1) do
      delete project_domain_url(@project, @domain)
    end
    assert_not_nil assigns(:domain)
    assert_not_nil assigns(:project)
    assert_redirected_to project_domains_url
  end

  test "should not destroy domain with invalid project" do
    login(@project_editor)
    assert_difference("Domain.current.count", 0) do
      delete project_domain_url(-1, @domain)
    end
    assert_nil assigns(:domain)
    assert_nil assigns(:project)
    assert_redirected_to root_url
  end
end
