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
end
