require 'test_helper'

class DesignsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @design = designs(:one)
  end

  test "should get copy" do
    get :copy, id: @design
    assert_not_nil assigns(:design)
    assert_template 'new'
    assert_response :success
  end

  test "should not get copy for invalid design" do
    get :copy, id: -1
    assert_nil assigns(:design)
    assert_redirected_to designs_path
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:designs)
  end

  test "should get paginated index" do
    get :index, format: 'js'
    assert_not_nil assigns(:designs)
    assert_template 'index'
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create design" do
    assert_difference('Design.count') do
      post :create, design: { project_id: projects(:one).id, description: "Design description", name: 'Design Three',
                              option_tokens: { "1338307879654" =>   { "variable_id" => ActiveRecord::Fixtures.identify(:dropdown) },
                                               "13383078795389" =>  { "variable_id" => ActiveRecord::Fixtures.identify(:checkbox) },
                                               "13383078797210" =>  { "variable_id" => ActiveRecord::Fixtures.identify(:radio) },
                                               "13383078798810" =>  { "variable_id" => ActiveRecord::Fixtures.identify(:string) },
                                               "133830787911168" => { "variable_id" => ActiveRecord::Fixtures.identify(:text) },
                                               "133830787913231" => { "variable_id" => ActiveRecord::Fixtures.identify(:integer) },
                                               "133830787914761" => { "variable_id" => ActiveRecord::Fixtures.identify(:numeric) },
                                               "133830787916252" => { "variable_id" => ActiveRecord::Fixtures.identify(:date) },
                                               "133830787917772" => { "variable_id" => ActiveRecord::Fixtures.identify(:file) }
                                             }
                            }
    end

    assert_not_nil assigns(:design)
    assert_equal 9, assigns(:design).variables.size
    assert_redirected_to design_path(assigns(:design))
  end

  test "should not create design without project" do
    assert_difference('Design.count', 0) do
      post :create, design: { project_id: nil, description: "Design description", name: 'Design Three', option_tokens: {} }
    end

    assert_not_nil assigns(:design)
    assert assigns(:design).errors.size > 0
    assert_equal ["can't be blank"], assigns(:design).errors[:project_id]
    assert_template 'new'
  end

  test "should create global design for librarian" do
    login(users(:librarian))
    assert_difference('Design.count', 1) do
      post :create, design: { project_id: nil, description: "Global Design", name: 'Global Design', option_tokens: {} }
    end

    assert_not_nil assigns(:design)
    assert_redirected_to design_path(assigns(:design))
  end

  test "should show design" do
    get :show, id: @design
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should not show invalid design" do
    get :show, id: -1
    assert_nil assigns(:design)
    assert_redirected_to designs_path
  end

  test "should print design" do
    get :print, id: @design
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should not print invalid design" do
    get :print, id: -1
    assert_nil assigns(:design)
    assert_response :success
  end

  test "should show design with all variable types" do
    get :show, id: designs(:all_variable_types)
    assert_response :success
  end

  test "should get variables" do
    post :variables, design: { description: "New description", name: 'Design Four' }, format: 'js'
    assert_template 'variables'
    assert_response :success
  end

  test "should add section" do
    post :add_section, design: { description: "New description", name: 'Design Four' }, format: 'js'
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:option)
    assert_template 'add_section'
    assert_response :success
  end

  test "should add variable" do
    post :add_variable, design: { description: "New description", name: 'Design Four' }, format: 'js'
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:option)
    assert_template 'add_variable'
    assert_response :success
  end

  test "should get selection" do
    post :selection, sheet: { design_id: designs(:all_variable_types).id }, format: 'js'
    assert_not_nil assigns(:sheet)
    assert_equal assigns(:design), designs(:all_variable_types)
    assert_template 'selection'
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @design
    assert_response :success
  end

  test "should get edit for global design for librarian" do
    login(users(:librarian))
    get :edit, id: designs(:global)
    assert_response :success
  end

  test "should update design" do
    put :update, id: @design, design: { project_id: projects(:one).id, description: @design.description, name: @design.name }
    assert_redirected_to design_path(assigns(:design))
  end

  test "should not update design with blank name" do
    put :update, id: @design, design: { project_id: projects(:one).id, description: @design.description, name: '' }
    assert_not_nil assigns(:design)
    assert assigns(:design).errors.size > 0
    assert_equal ["can't be blank"], assigns(:design).errors[:name]
    assert_template 'edit'
  end

  test "should not update invalid design" do
    put :update, id: -1, design: { project_id: projects(:one).id, description: @design.description, name: @design.name }
    assert_nil assigns(:design)
    assert_redirected_to designs_path
  end

  test "should update for global design for librarian" do
    login(users(:librarian))
    put :update, id: designs(:global), design: { project_id: nil, description: designs(:global).description, name: designs(:global).name }
    assert_redirected_to design_path(assigns(:design))
  end

  test "should destroy design" do
    assert_difference('Design.current.count', -1) do
      delete :destroy, id: @design
    end

    assert_redirected_to designs_path
  end

  test "should destroy global design for librarian" do
    login(users(:librarian))
    assert_difference('Design.current.count', -1) do
      delete :destroy, id: designs(:global)
    end

    assert_redirected_to designs_path
  end
end
