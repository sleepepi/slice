# frozen_string_literal: true

require 'test_helper'

# Tests to assure documentation pages can be publicly viewed.
class DocsControllerTest < ActionDispatch::IntegrationTest
  test 'should get docs index' do
    get docs_path
    assert_response :success
  end

  test 'should get technical' do
    get docs_technical_path
    assert_response :success
  end

  test 'should get randomization schemes' do
    get docs_randomization_schemes_path
    assert_response :success
  end

  test 'should get minimization' do
    get docs_minimization_path
    assert_response :success
  end

  test 'should get permuted block' do
    get docs_permuted_block_path
    assert_response :success
  end
end
