# frozen_string_literal: true

require "test_helper"

# Tests to assure that designs can be created and updated by project editors.
class DesignsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_editor = users(:regular)
    @project = projects(:one)
    @design = designs(:one)
  end

  def design_params
    {
      name: "Design Three"
    }
  end

  test "should show design reorder mode" do
    login(@project_editor)
    get reorder_project_design_url(@project, @design)
    assert_template "reorder"
    assert_response :success
  end

  test "should get index" do
    login(@project_editor)
    get project_designs_url(@project)
    assert_response :success
  end

  test "should not get index with invalid project" do
    login(@project_editor)
    get project_designs_url(-1)
    assert_redirected_to root_url
  end

  test "should get index by design" do
    login(@project_editor)
    get project_designs_url(@project), params: { order: "design" }
    assert_response :success
  end

  test "should get index by design desc" do
    login(@project_editor)
    get project_designs_url(@project), params: { order: "design desc" }
    assert_response :success
  end

  test "should get index by category" do
    login(@project_editor)
    get project_designs_url(@project), params: { order: "category" }
    assert_response :success
  end

  test "should get index by category desc" do
    login(@project_editor)
    get project_designs_url(@project), params: { order: "category desc" }
    assert_response :success
  end

  test "should get index by variables" do
    login(@project_editor)
    get project_designs_url(@project), params: { order: "variables" }
    assert_response :success
  end

  test "should get index by variables desc" do
    login(@project_editor)
    get project_designs_url(@project), params: { order: "variables desc" }
    assert_response :success
  end

  test "should get new" do
    login(@project_editor)
    get new_project_design_url(@project)
    assert_response :success
  end

  test "should create design" do
    login(@project_editor)
    assert_difference("Design.count") do
      post project_designs_url(@project), params: {
        design: design_params
      }
    end
    assert_redirected_to edit_project_design_url(assigns(:design).project, assigns(:design))
  end

  test "should not create design with blank name" do
    login(@project_editor)
    assert_difference("Design.count", 0) do
      post project_designs_url(@project), params: {
        design: design_params.merge(name: "")
      }
    end
    assert_template "new"
    assert_response :success
  end

  test "should create design with questions" do
    login(@project_editor)
    assert_difference("Variable.count", 3) do
      assert_difference("Design.count") do
        post project_designs_url(@project), params: {
          design: {
            name: "Design With Questions",
            short_name: "DEWQUE",
            questions: [
              { question_name: "String Question", question_type: "string" },
              { question_name: "Integer Question", question_type: "integer" },
              { question_name: "Gender", question_type: "radio" }
            ]
          }
        }
      end
    end
    assert_equal "Design With Questions", assigns(:design).name
    assert_equal "DEWQUE", assigns(:design).short_name
    assert_redirected_to edit_project_design_url(assigns(:design).project, assigns(:design))
  end

  test "should create design and save parseable redirect_url" do
    login(@project_editor)
    assert_difference("Design.count") do
      post project_designs_url(@project), params: {
        design: {
          name: "Public with Valid Redirect",
          redirect_url: "http://example.com"
        }
      }
    end
    assert_equal "http://example.com", assigns(:design).redirect_url
    assert_redirected_to edit_project_design_url(assigns(:design).project, assigns(:design))
  end

  test "should create design but not save non http redirect_url" do
    login(@project_editor)
    assert_difference("Design.count") do
      post project_designs_url(@project), params: {
        design: {
          name: "Public with Invalid Redirect",
          redirect_url: "fake123"
        }
      }
    end
    assert_equal "", assigns(:design).redirect_url
    assert_redirected_to edit_project_design_url(assigns(:design).project, assigns(:design))
  end

  test "should create design but not save nonparseable redirect_url" do
    login(@project_editor)
    assert_difference("Design.count") do
      post project_designs_url(@project), params: {
        design: {
          name: "Public with Invalid Redirect",
          redirect_url: "fa\\ke"
        }
      }
    end
    assert_equal "", assigns(:design).redirect_url
    assert_redirected_to edit_project_design_url(assigns(:design).project, assigns(:design))
  end

  test "should not create design with invalid project" do
    login(@project_editor)
    assert_difference("Design.count", 0) do
      post project_designs_url(-1), params: { design: design_params }
    end
    assert_redirected_to root_url
  end

  # test "should not create design with a duplicated variable" do
  #   login(@project_editor)
  #   assert_difference("Design.count", 0) do
  #     post :create, project_id: @project, design: { name: "Design Three",
  #                             option_tokens: [ { "variable_id" => ActiveRecord::FixtureSet.identify(:dropdown) },
  #                                              { "variable_id" => ActiveRecord::FixtureSet.identify(:dropdown) }
  #                                            ]
  #                           }
  #   end
  #   assert_equal ["can only be added once"], assigns(:design).errors[:variables]
  #   assert_template "new"
  # end

  # test "should not create design with a duplicated section name" do
  #   login(@project_editor)
  #   assert_difference("Design.count", 0) do
  #     post :create, project_id: @project, design: { name: "Design with Sections",
  #                             option_tokens: [ { "section_name" => "Section A" },
  #                                              { "section_name" => "Section A" }
  #                                            ]
  #                           }
  #   end
  #   assert_equal ["must be unique"], assigns(:design).errors[:section_names]
  #   assert_template "new"
  # end

  test "should show design" do
    login(@project_editor)
    get project_design_url(@project, @design)
    assert_response :success
  end

  test "should show design for project with no sites" do
    login(@project_editor)
    get project_design_url(projects(:no_sites), designs(:no_sites))
    assert_response :success
  end

  test "should not show invalid design" do
    login(@project_editor)
    get project_design_url(@project, -1)
    assert_redirected_to project_designs_url(@project)
  end

  test "should not show design with invalid project" do
    login(@project_editor)
    get project_design_url(-1, @design)
    assert_redirected_to root_url
  end

  test "should print design" do
    skip if ENV["TRAVIS"] # Skip this test on Travis since Travis can't generate PDFs
    login(@project_editor)
    get print_project_design_url(@project, designs(:all_variable_types))
    assert_response :success
  end

  test "should not print invalid design" do
    skip if ENV["TRAVIS"] # Skip this test on Travis since Travis can't generate PDFs
    login(@project_editor)
    get print_project_design_url(@project, -1)
    assert_redirected_to project_designs_url(assigns(:project))
  end

  test "should show design if PDF fails to render" do
    skip if ENV["TRAVIS"] # Skip this test on Travis since Travis can't generate PDFs
    login(@project_editor)
    begin
      original_latex = ENV["latex_location"]
      ENV["latex_location"] = "echo #{original_latex}"
      get print_project_design_url(@project, designs(:has_no_validations))
      assert_response :ok
    ensure
      ENV["latex_location"] = original_latex
    end
  end

  test "should show design with all variable types" do
    login(@project_editor)
    get project_design_url(@project, designs(:all_variable_types))
    assert_response :success
  end

  test "should get edit" do
    login(@project_editor)
    get edit_project_design_url(@project, @design)
    assert_response :success
  end

  test "should not get edit for invalid design" do
    login(@project_editor)
    get edit_project_design_url(@project, -1)
    assert_redirected_to project_designs_url(assigns(:project))
  end

  test "should not get edit with invalid project" do
    login(@project_editor)
    get edit_project_design_url(-1, @design)
    assert_redirected_to root_url
  end

  test "should update design" do
    login(@project_editor)
    patch project_design_url(@project, @design, format: "js"), params: {
      design: design_params.merge(name: "Updated Name")
    }
    assert_equal "Updated Name", assigns(:design).name
    assert_template "show"
  end

  test "should not update design with blank name" do
    login(@project_editor)
    patch project_design_url(@project, @design, format: "js"), params: {
      design: design_params.merge(name: "")
    }
    assert_template "edit"
    assert_response :success
  end

  test "should update design and make publicly available" do
    login(@project_editor)
    patch project_design_url(@project, @design, format: "js"), params: {
      design: design_params.merge(publicly_available: "1")
    }
    assert_equal "design-one", assigns(:design).survey_slug
    assert_equal true, assigns(:design).publicly_available
    assert_template "show"
  end

  test "should update design and make custom survey slug" do
    login(@project_editor)
    patch project_design_url(@project, @design, format: "js"), params: {
      design: design_params.merge(publicly_available: "1", survey_slug: "design-one-custom")
    }
    assert_equal "design-one-custom", assigns(:design).survey_slug
    assert_equal true, assigns(:design).publicly_available
    assert_template "show"
  end

  # test "should not update invalid design" do
  #   login(@project_editor)
  #   patch :update, id: -1, project_id: @project, design: { name: @design.name }
  #   assert_redirected_to project_designs_url(assigns(:project))
  # end

  # test "should not update design with invalid project" do
  #   login(@project_editor)
  #   patch :update, id: @design, project_id: -1, design: { name: @design.name }
  #   assert_redirected_to root_url
  # end

  test "should destroy design" do
    login(@project_editor)
    assert_difference("Design.current.count", -1) do
      delete project_design_url(@project, @design)
    end
    assert_redirected_to project_designs_url(assigns(:project))
  end

  test "should not destroy design with invalid project" do
    login(@project_editor)
    assert_difference("Design.current.count", 0) do
      delete project_design_url(-1, @design)
    end
    assert_redirected_to root_url
  end
end
