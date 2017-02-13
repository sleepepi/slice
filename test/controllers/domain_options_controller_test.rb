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

  test 'should not create domain option with blank name' do
    login(@project_editor)
    assert_difference('DomainOption.count', 0) do
      post project_domain_domain_options_path(@project, @domain), params: {
        domain_option: domain_option_params.merge(name: '', value: '4')
      }
    end
    assert_template 'new'
    assert_response :success
  end

  test 'should not create domain option with colon in name' do
    login(@project_editor)
    assert_difference('DomainOption.count', 0) do
      post project_domain_domain_options_path(@project, @domain), params: {
        domain_option: domain_option_params.merge(name: 'Extreme', value: '4:4')
      }
    end
    assert_template 'new'
    assert_response :success
  end

  test 'should not create domain option with non-unique value' do
    login(@project_editor)
    assert_difference('DomainOption.count', 0) do
      post project_domain_domain_options_path(@project, @domain), params: {
        domain_option: domain_option_params.merge(name: 'Extreme', value: '3')
      }
    end
    assert_template 'new'
    assert_response :success
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

  # Ex: Domain Option value is 1, and is tried to change to 2.
  # If domain_option does not have any associated sheet variables, grids, or
  # responses, then let it change to 2 and associate any underlying values to
  # domain.
  # Elisf domain_option has associated values (1), and values of 2 exist as well
  # then prevent this as it would merge underlying values (1 and 2) and we want
  # to prevent this.
  # Finally if it has associated values (1) but no values of 2 exist, then updating
  # the value of the domain option can take place and requires no changes to
  # associated values as they are linked on domain_option_id
  #

  # The -9 domain option has one underlying sheet_variable captured, and the
  # value of 36 is captured on a grid. Slice prevents merging of values by
  # changing domain option values, and hence prevents this change which would
  # merge two differing sets of values.
  test 'should not update domain option to merge with other existing values on sheet' do
    login(@project_editor)
    assert_difference('Grid.where(value: nil).count', 0) do
      patch project_domain_domain_option_path(@project, domains(:integer_unknown), domain_options(:integer_unknown_9)), params: {
        domain_option: {
          value: '36',
          name: 'Merge -9 to 36',
          description: '',
          site_id: nil,
          missing_code: '0',
          archived: '0'
        }
      }
    end
    assert_not_nil assigns(:domain_option)
    assert_equal ['merging not permitted'], assigns(:domain_option).errors[:value]
    assert_template 'edit'
    assert_response :success
  end

  # The -9 domain option has one underlying sheet_variable captured, however,
  # the value -11 does not exist in any underlying sheet_variables, grids, or
  # responses, allowing the domain option value to be remapped as no differering
  # values are being merged.
  test 'should update domain option to value that does not exist in collected data' do
    login(@project_editor)
    assert_difference('SheetVariable.where(value: nil).count', 0) do
      assert_difference('Response.where(value: nil).count', 0) do
        assert_difference('Grid.where(value: nil).count', 0) do
          patch project_domain_domain_option_path(
            @project, domains(:integer_unknown), domain_options(:integer_unknown_9)
          ), params: {
            domain_option: {
              value: '-11',
              name: 'Change -9 to -11',
              description: '',
              site_id: nil,
              missing_code: '1',
              archived: '0'
            }
          }
        end
      end
    end
    assert_not_nil assigns(:domain_option)
    assert_equal '-11', assigns(:domain_option).value
    assert_redirected_to [@project, domains(:integer_unknown), domain_options(:integer_unknown_9)]
  end

  # The -10 domain option has no underlying collected sheet_variables,
  # responses, or grids, which allows it to be remapped to an existing collected
  # value of 36 (one occurence on a grid).
  test 'should update domain option with no collected values to value that has been collected on sheets' do
    login(@project_editor)
    assert_difference('Grid.where(value: nil).count') do
      patch project_domain_domain_option_path(
        @project, domains(:integer_unknown), domain_options(:integer_unknown_10)
      ), params: {
        domain_option: {
          value: '36',
          name: 'Change -10 to 36',
          description: '',
          site_id: nil,
          missing_code: '0',
          archived: '0'
        }
      }
    end
    assert_not_nil assigns(:domain_option)
    assert_equal '36', assigns(:domain_option).value
    assert_redirected_to [@project, domains(:integer_unknown), domain_options(:integer_unknown_10)]
  end

  test 'should destroy domain option' do
    login(@project_editor)
    assert_difference('DomainOption.count', -1) do
      delete project_domain_domain_option_path(@project, @domain, @domain_option)
    end
    assert_redirected_to project_domain_domain_options_path(@project, @domain)
  end
end
