# frozen_string_literal: true

require 'test_helper'

# Tests to assure that block size multipliers can be specified for randomization
# schemes using permuted-block algorithm.
class BlockSizeMultipliersControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)

    @published_scheme = randomization_schemes(:one)
    @published_block_size_multiplier = block_size_multipliers(:one)

    @randomization_scheme = randomization_schemes(:two)
    @block_size_multiplier = block_size_multipliers(:six)
  end

  test 'should get index' do
    get :index, project_id: @project, randomization_scheme_id: @randomization_scheme
    assert_response :success
    assert_not_nil assigns(:block_size_multipliers)
  end

  test 'should get new' do
    get :new, project_id: @project, randomization_scheme_id: @randomization_scheme
    assert_response :success
  end

  test 'should not get new for published randomization scheme' do
    get :new, project_id: @project, randomization_scheme_id: @published_scheme
    assert_redirected_to project_randomization_scheme_block_size_multipliers_path(
      assigns(:project), assigns(:randomization_scheme)
    )
  end

  test 'should create block size multiplier' do
    assert_difference('BlockSizeMultiplier.count') do
      post :create, project_id: @project, randomization_scheme_id: @randomization_scheme,
                    block_size_multiplier: { value: 5, allocation: 1 }
    end

    assert_redirected_to project_randomization_scheme_block_size_multiplier_path(
      assigns(:project), assigns(:randomization_scheme), assigns(:block_size_multiplier)
    )
  end

  test 'should create block size multiplier with default values' do
    assert_difference('BlockSizeMultiplier.count') do
      post :create, project_id: @project, randomization_scheme_id: @randomization_scheme,
                    block_size_multiplier: { value: 2, allocation: '' }
    end

    assert_not_nil assigns(:block_size_multiplier)
    assert_equal 2, assigns(:block_size_multiplier).value
    assert_equal 0, assigns(:block_size_multiplier).allocation

    assert_redirected_to project_randomization_scheme_block_size_multiplier_path(
      assigns(:project), assigns(:randomization_scheme), assigns(:block_size_multiplier)
    )
  end

  test 'should not create block size multiplier for published randomization scheme' do
    assert_difference('BlockSizeMultiplier.count', 0) do
      post :create, project_id: @project, randomization_scheme_id: @published_scheme,
                    block_size_multiplier: { value: 5, allocation: 1 }
    end

    assert_redirected_to project_randomization_scheme_block_size_multipliers_path(
      assigns(:project), assigns(:randomization_scheme)
    )
  end

  test 'should not create block size multiplier with invalid value and allocation' do
    assert_difference('BlockSizeMultiplier.count', 0) do
      post :create, project_id: @project, randomization_scheme_id: @randomization_scheme,
                    block_size_multiplier: { value: 0, allocation: -1 }
    end

    assert_not_nil assigns(:block_size_multiplier)
    assert assigns(:block_size_multiplier).errors.size > 0
    assert_equal ['must be greater than or equal to 1'], assigns(:block_size_multiplier).errors[:value]
    assert_equal ['must be greater than or equal to 0'], assigns(:block_size_multiplier).errors[:allocation]
    assert_template 'new'
  end

  test 'should show block size multiplier' do
    get :show, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @block_size_multiplier
    assert_response :success
  end

  test 'should get edit' do
    get :edit, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @block_size_multiplier
    assert_response :success
  end

  test 'should not get edit for published randomization scheme' do
    get :edit, project_id: @project, randomization_scheme_id: @published_scheme, id: @published_block_size_multiplier
    assert_redirected_to project_randomization_scheme_block_size_multiplier_path(
      assigns(:project), assigns(:randomization_scheme), assigns(:block_size_multiplier)
    )
  end

  test 'should update block size multiplier' do
    patch :update, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @block_size_multiplier,
                   block_size_multiplier: { value: @block_size_multiplier.value, allocation: 3 }
    assert_redirected_to project_randomization_scheme_block_size_multiplier_path(
      assigns(:project), assigns(:randomization_scheme), assigns(:block_size_multiplier)
    )
  end

  test 'should not update block size multiplier for published randomization scheme' do
    patch :update, project_id: @project, randomization_scheme_id: @published_scheme,
                   id: @published_block_size_multiplier,
                   block_size_multiplier: { value: 2, allocation: 3 }
    assert_equal 1, assigns(:block_size_multiplier).value
    assert_equal 2, assigns(:block_size_multiplier).allocation
    assert_redirected_to project_randomization_scheme_block_size_multiplier_path(
      assigns(:project), assigns(:randomization_scheme), assigns(:block_size_multiplier)
    )
  end

  test 'should not update block size multiplier with invalid value and allocation' do
    patch :update, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @block_size_multiplier,
                   block_size_multiplier: { value: 0, allocation: -1 }
    assert_not_nil assigns(:block_size_multiplier)
    assert assigns(:block_size_multiplier).errors.size > 0
    assert_equal ['must be greater than or equal to 1'], assigns(:block_size_multiplier).errors[:value]
    assert_equal ['must be greater than or equal to 0'], assigns(:block_size_multiplier).errors[:allocation]
    assert_template 'edit'
  end

  test 'should destroy block size multiplier' do
    assert_difference('BlockSizeMultiplier.current.count', -1) do
      delete :destroy, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @block_size_multiplier
    end

    assert_redirected_to project_randomization_scheme_block_size_multipliers_path(
      assigns(:project), assigns(:randomization_scheme)
    )
  end

  test 'should not destroy block size multiplier for published randomization scheme' do
    assert_difference('BlockSizeMultiplier.current.count', 0) do
      delete :destroy, project_id: @project, randomization_scheme_id: @published_scheme,
                       id: @published_block_size_multiplier
    end

    assert_redirected_to project_randomization_scheme_block_size_multiplier_path(
      assigns(:project), assigns(:randomization_scheme), assigns(:block_size_multiplier)
    )
  end
end
