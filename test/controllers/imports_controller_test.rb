# frozen_string_literal: true

require 'test_helper'

# Tests to assure that designs and associated data can be imported.
class ImportsControllerTest < ActionController::TestCase
  setup do
    @editor = users(:project_one_editor)
    @project = projects(:one)
    @design = designs(:one)
  end

  test 'should get new as editor' do
    login(@editor)
    get :new, project_id: @project
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:variables)
    assert_response :success
  end

  test 'should require file before proceeding to column specification for design imports as editor' do
    login(@editor)
    post :create, project_id: @project, design: { csv_file: '' }
    assert_equal 0, assigns(:variables).size
    assert assigns(:design).errors.size > 0
    assert_equal ['must be selected'], assigns(:design).errors[:csv_file]
    assert_template 'new'
    assert_response :success
  end

  test 'should import data for new design as editor' do
    login(@editor)
    assert_difference('Design.count', 1) do
      assert_difference('Variable.count', 5) do
        post :create, project_id: @project,
                      design: {
                        csv_file: fixture_file_upload('../../test/support/design_import.csv'),
                        name: 'Design Import'
                      },
                      variables: {
                        'store_id' => { display_name: 'Store ID', variable_type: 'integer' },
                        'gpa' => { display_name: 'GPA', variable_type: 'numeric' },
                        'buy_date' => { display_name: 'Buy Date', variable_type: 'date' },
                        'name' => { display_name: 'First Name', variable_type: 'string' },
                        'gender' => { display_name: 'Gender', variable_type: 'string' }
                      }
      end
    end
    assert_redirected_to project_design_path(assigns(:design).project, assigns(:design))
  end

  test 'should not import data for new design with blank name as editor' do
    login(@editor)
    assert_difference('Design.count', 0) do
      assert_difference('Variable.count', 0) do
        post :create, project_id: @project,
                      design: {
                        csv_file: fixture_file_upload('../../test/support/design_import.csv'),
                        name: ''
                      },
                      variables: {
                        'store_id' => { display_name: 'Store ID', variable_type: 'integer' },
                        'gpa' => { display_name: 'GPA', variable_type: 'numeric' },
                        'buy_date' => { display_name: 'Buy Date', variable_type: 'date' },
                        'name' => { display_name: 'First Name', variable_type: 'string' },
                        'gender' => { display_name: 'Gender', variable_type: 'string' }
                      }
      end
    end
    assert_equal 5, assigns(:variables).size
    assert_template 'new'
    assert_response :success
  end

  test 'should load file and present importable columns for new design with blank header columns as editor' do
    login(@editor)
    post :create, project_id: @project,
                  design: {
                    csv_file: fixture_file_upload('../../test/support/design_import_with_blank_columns.csv')
                  }

    assert_equal 4, assigns(:variables).size

    assert_template 'new'
    assert_response :success
  end

  test 'should import data for new design with blank header columns as editor' do
    login(@editor)
    assert_difference('Design.count', 1) do
      assert_difference('Variable.count', 4) do
        post :create, project_id: @project,
                      design: {
                        csv_file: fixture_file_upload('../../test/support/design_import_with_blank_columns.csv'),
                        name: 'Design Import'
                      },
                      variables: {
                        'gpa' => { display_name: 'GPA', variable_type: 'numeric' },
                        'buy_date' => { display_name: 'Buy Date', variable_type: 'date' },
                        'name' => { display_name: 'First Name', variable_type: 'string' },
                        'gender' => { display_name: 'Gender', variable_type: 'string' }
                      }
      end
    end
    assert_redirected_to project_design_path(assigns(:design).project, assigns(:design))
  end

  test 'should show progress as editor' do
    login(@editor)
    post :progress, project_id: @project, id: @design, format: 'js'
    assert_not_nil assigns(:design)
    assert_template 'progress'
    assert_response :success
  end

  test 'should get edit as editor' do
    login(@editor)
    get :edit, id: @design, project_id: @project
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:variables)
    assert_response :success
  end

  test 'should require file before proceeding to column specification for updating design imports as editor' do
    login(@editor)
    patch :update, id: @design, project_id: @project, design: { csv_file: '' }

    assert_equal 0, assigns(:variables).size
    assert assigns(:design).errors.size > 0
    assert_equal ['must be selected'], assigns(:design).errors[:csv_file]

    assert_template 'edit'
    assert_response :success
  end

  test 'should reimport data for existing design as editor' do
    login(@editor)
    assert_difference('Design.count', 0) do
      assert_difference('Variable.count', 0) do
        patch :update, id: @design, project_id: @project,
                       design: { csv_file: fixture_file_upload('../../test/support/design_import.csv') },
                       variables: {
                         'store_id' => { display_name: 'Store ID', variable_type: 'integer' },
                         'gpa' => { display_name: 'GPA', variable_type: 'numeric' },
                         'buy_date' => { display_name: 'Buy Date', variable_type: 'date' },
                         'name' => { display_name: 'First Name', variable_type: 'string' },
                         'gender' => { display_name: 'Gender', variable_type: 'string' }
                       }
      end
    end
    assert_redirected_to project_design_path(assigns(:design).project, assigns(:design))
  end

  test 'should not reimport data for existing design without variables as editor' do
    login(@editor)
    assert_difference('Design.count', 0) do
      assert_difference('Variable.count', 0) do
        patch :update, id: @design, project_id: @project,
                       design: { csv_file: fixture_file_upload('../../test/support/design_import.csv') },
                       variables: {}
      end
    end
    assert_template 'edit'
    assert_response :success
  end

  test 'should get new json import as editor' do
    login(@editor)
    get :json_new, project_id: @project
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should create design from json template as editor' do
    login(@editor)
    assert_difference('Section.count', 10) do
      assert_difference('Domain.count', 8) do
        assert_difference('Variable.count', 27) do
          assert_difference('Design.count') do
            post :json_create, project_id: projects(:empty),
                               json_file: fixture_file_upload('../../test/support/designs/all_variables.json')
          end
        end
      end
    end

    assert_not_nil assigns(:project)
    design = assigns(:project).designs.last
    assert_equal 'All Variables', design.name
    assert_equal 35, design.design_options.count
    assert_redirected_to project_designs_path(assigns(:project))
  end

  test 'should not create design from invalid json template as editor' do
    login(@editor)
    assert_difference('Design.count', 0) do
      post :json_create, project_id: projects(:empty),
                         json_file: fixture_file_upload('../../test/support/design_import.csv')
    end

    assert_not_nil assigns(:project)
    assert_template 'json_new'
    assert_response :success
  end

  test 'should not create design from blank json template as editor' do
    login(@editor)
    assert_difference('Design.count', 0) do
      post :json_create, project_id: projects(:empty)
    end

    assert_not_nil assigns(:project)
    assert_template 'json_new'
    assert_response :success
  end
end
