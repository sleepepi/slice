require 'test_helper'

class DesignsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @design = designs(:one)
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
      post :create, design: { description: "Design description", name: 'Design Three',
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

  test "should show design" do
    get :show, id: @design
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

  test "should add variable" do
    post :add_variable, design: { description: "New description", name: 'Design Four' }, format: 'js'
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

  test "should update design" do
    put :update, id: @design, design: { description: @design.description, name: @design.name }
    assert_redirected_to design_path(assigns(:design))
  end

  test "should destroy design" do
    assert_difference('Design.current.count', -1) do
      delete :destroy, id: @design
    end

    assert_redirected_to designs_path
  end
end
