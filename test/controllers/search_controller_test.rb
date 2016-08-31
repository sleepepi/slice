# frozen_string_literal: true

require 'test_helper'

# Tests to assure that search results are returned.
class SearchControllerTest < ActionDispatch::IntegrationTest
  test 'should get search' do
    login(users(:valid))
    get search_url, params: { search: '' }
    assert_not_nil assigns(:subjects)
    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:designs)
    assert_not_nil assigns(:variables)
    assert_not_nil assigns(:objects)
    assert_response :success
  end

  test 'should get search and redirect' do
    login(users(:valid))
    get search_url, params: { search: 'Project With One Design' }
    assert_not_nil assigns(:subjects)
    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:designs)
    assert_not_nil assigns(:variables)
    assert_not_nil assigns(:objects)
    assert_equal 1, assigns(:objects).size
    assert_redirected_to assigns(:objects).first
  end

  test 'should get search typeahead' do
    login(users(:valid))
    get search_url(format: 'json'), params: { search: 'abc' }
    assert_not_nil assigns(:subjects)
    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:designs)
    assert_not_nil assigns(:variables)
    assert_not_nil assigns(:objects)
    assert_response :success
  end
end
