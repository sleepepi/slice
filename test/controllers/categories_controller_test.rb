require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @category = categories(:one)
  end

  test 'should get index' do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:categories)
  end

  test 'should not get index with invalid project' do
    get :index, project_id: -1
    assert_nil assigns(:categories)
    assert_redirected_to root_path
  end

  test 'should get new' do
    get :new, project_id: @project
    assert_response :success
  end

  test 'should create category' do
    assert_difference('Category.count') do
      post :create, project_id: @project, category: { name: 'New Category', slug: 'new-category', description: @category.description, position: @category.position, use_for_adverse_events: @category.use_for_adverse_events }
    end

    assert_redirected_to project_category_path(assigns(:project), assigns(:category))
  end

  test 'should not create category with blank name' do
    assert_difference('Category.count', 0) do
      post :create, project_id: @project, category: { name: '', slug: '', description: @category.description, position: @category.position, use_for_adverse_events: @category.use_for_adverse_events }
    end

    assert_not_nil assigns(:category)
    assert assigns(:category).errors.size > 0
    assert_equal ["can't be blank"], assigns(:category).errors[:name]
    assert_template 'new'
  end

  test 'should not create category with invalid project' do
    assert_difference('Category.count', 0) do
      post :create, project_id: -1, category: { name: 'New Category', slug: 'new-category', description: @category.description, position: @category.position, use_for_adverse_events: @category.use_for_adverse_events }
    end

    assert_nil assigns(:category)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end

  test 'should show category' do
    get :show, project_id: @project, id: @category
    assert_not_nil assigns(:category)
    assert_response :success
  end

  test 'should not show category with invalid project' do
    get :show, project_id: -1, id: @category
    assert_nil assigns(:category)
    assert_redirected_to root_path
  end

  test 'should get edit' do
    get :edit, project_id: @project, id: @category
    assert_not_nil assigns(:category)
    assert_response :success
  end

  test 'should not get edit with invalid project' do
    get :edit, project_id: -1, id: @category
    assert_nil assigns(:category)
    assert_redirected_to root_path
  end

  test 'should update category' do
    patch :update, project_id: @project, id: @category, category: { name: 'Updated Category', slug: 'updated-category', description: @category.description, position: @category.position, use_for_adverse_events: @category.use_for_adverse_events }
    assert_redirected_to project_category_path(assigns(:project), assigns(:category))
  end

  test 'should not update category with blank name' do
    patch :update, project_id: @project, id: @category, category: { name: '', slug: @category.slug, description: @category.description, position: @category.position, use_for_adverse_events: @category.use_for_adverse_events }

    assert_not_nil assigns(:category)
    assert assigns(:category).errors.size > 0
    assert_equal ["can't be blank"], assigns(:category).errors[:name]
    assert_template 'edit'
  end

  test 'should not update category with invalid project' do
    patch :update, project_id: -1, id: @category, category: { name: 'Updated Category', slug: 'updated-category', description: @category.description, position: @category.position, use_for_adverse_events: @category.use_for_adverse_events }

    assert_nil assigns(:category)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end

  test 'should destroy category' do
    assert_difference('Category.current.count', -1) do
      delete :destroy, project_id: @project, id: @category
    end

    assert_not_nil assigns(:category)
    assert_not_nil assigns(:project)

    assert_redirected_to project_categories_path(assigns(:project))
  end

  test 'should not destroy category with invalid project' do
    assert_difference('Category.current.count', 0) do
      delete :destroy, project_id: -1, id: @category
    end

    assert_nil assigns(:category)
    assert_nil assigns(:project)

    assert_redirected_to root_path
  end
end
