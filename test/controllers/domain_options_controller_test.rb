# frozen_string_literal: true

require 'test_helper'

# Tests to make sure that domain options can be created by project editors.
class DomainOptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_editor = users(:project_one_editor)
    @project = projects(:one)
    @domain = domains(:one)
    @domain_option = domain_options(:one_easy)
  end

  def domain_option_params
    {
      name: @domain_option.name,
      value: @domain_option.value,
      description: @domain_option.description,
      site_id: @domain_option.site_id,
      missing_code: @domain_option.missing_code,
      archived: @domain_option.archived
    }
  end

  test 'should get index' do
    login(@project_editor)
    get project_domain_domain_options_path(@project, @domain)
    assert_response :success
  end

  test 'should get new' do
    login(@project_editor)
    get new_project_domain_domain_option_path(@project, @domain)
    assert_response :success
  end

  test 'should create domain option' do
    login(@project_editor)
    assert_difference('DomainOption.count') do
      post project_domain_domain_options_path(@project, @domain), params: {
        domain_option: domain_option_params.merge(name: 'Extreme', value: '4')
      }
    end
    assert_redirected_to [@project, @domain, DomainOption.last]
  end

  test 'should show domain option' do
    login(@project_editor)
    get project_domain_domain_option_path(@project, @domain, @domain_option)
    assert_response :success
  end

  test 'should get edit' do
    login(@project_editor)
    get edit_project_domain_domain_option_path(@project, @domain, @domain_option)
    assert_response :success
  end

  test 'should update domain option' do
    login(@project_editor)
    patch project_domain_domain_option_path(@project, @domain, @domain_option), params: {
      domain_option: domain_option_params
    }
    assert_redirected_to [@project, @domain, @domain_option]
  end

  test 'should destroy domain option' do
    login(@project_editor)
    assert_difference('DomainOption.count', -1) do
      delete project_domain_domain_option_path(@project, @domain, @domain_option)
    end
    assert_redirected_to project_domain_domain_options_path(@project, @domain)
  end
end
