# frozen_string_literal: true

require 'test_helper'

class DesignOptionsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @design = designs(:one)
    @design_option = design_options(:one_one)
  end

  test "should get new" do
    xhr :get, :new, project_id: @project, design_id: @design, position: 0, format: 'js'
    assert_response :success
  end

  test "should get new section" do
    xhr :get, :new_section, project_id: @project, design_id: @design, design_option: { position: 0 }, format: 'js'
    assert_response :success
  end

  test "should get new string variable" do
    xhr :get, :new_variable, project_id: @project, design_id: @design, design_option: { position: 0 }, variable: { variable_type: 'string' }, format: 'js'
    assert_template partial: '_new_form_variable'
    assert_response :success
  end

  test "should get new grid variable" do
    xhr :get, :new_variable, project_id: @project, design_id: @design, design_option: { position: 0 }, variable: { variable_type: 'grid' }, format: 'js'
    assert_template partial: '_new_form_variable'
    assert_response :success
  end

  test "should get new existing variable" do
    xhr :get, :new_existing_variable, project_id: @project, design_id: @design, design_option: { position: 0 }, format: 'js'
    assert_template partial: '_new_existing_variable'
    assert_response :success
  end

  test "should get edit section" do
    xhr :get, :edit, project_id: @project, design_id: designs(:sections_and_variables), id: design_options(:sections_and_variables_sectiona), format: 'js'
    assert_template partial: '_edit'
    assert_response :success
  end

  test "should get edit variable" do
    xhr :get, :edit, project_id: @project, design_id: designs(:sections_and_variables), id: design_options(:sections_and_variables_dropdown), format: 'js'
    assert_template partial: '_edit'
    assert_response :success
  end

  test "should get edit variable append" do
    xhr :get, :edit_variable, project_id: @project, design_id: designs(:all_variable_types), id: design_options(:all_variable_types_string), attribute: 'append', format: 'js'
    assert_template partial: '_append'
    assert_response :success
  end

  test "should get edit variable autocomplete" do
    xhr :get, :edit_variable, project_id: @project, design_id: designs(:all_variable_types), id: design_options(:all_variable_types_string), attribute: 'autocomplete', format: 'js'
    assert_template partial: '_autocomplete'
    assert_response :success
  end

  test "should get edit variable calculation" do
    xhr :get, :edit_variable, project_id: @project, design_id: designs(:all_variable_types), id: design_options(:all_variable_types_calculated), attribute: 'calculation', format: 'js'
    assert_template partial: '_calculation'
    assert_response :success
  end

  test "should get edit variable date" do
    xhr :get, :edit_variable, project_id: @project, design_id: designs(:all_variable_types), id: design_options(:all_variable_types_string), attribute: 'date', format: 'js'
    assert_template partial: '_date'
    assert_response :success
  end

  test "should get edit variable grid rows" do
    xhr :get, :edit_variable, project_id: @project, design_id: designs(:has_grid), id: design_options(:has_grid_grid), attribute: 'grid_rows', format: 'js'
    assert_template partial: '_grid_rows'
    assert_response :success
  end

  test "should get edit variable grid variables" do
    xhr :get, :edit_variable, project_id: @project, design_id: designs(:has_grid), id: design_options(:has_grid_grid), attribute: 'grid_variables', format: 'js'
    assert_template partial: '_grid_variables'
    assert_response :success
  end

  test "should get edit variable prepend" do
    xhr :get, :edit_variable, project_id: @project, design_id: designs(:all_variable_types), id: design_options(:all_variable_types_string), attribute: 'prepend', format: 'js'
    assert_template partial: '_prepend'
    assert_response :success
  end

  test "should get edit variable ranges" do
    xhr :get, :edit_variable, project_id: @project, design_id: designs(:all_variable_types), id: design_options(:all_variable_types_calculated), attribute: 'ranges', format: 'js'
    assert_template partial: '_ranges'
    assert_response :success
  end

  test "should get edit variable units" do
    xhr :get, :edit_variable, project_id: @project, design_id: designs(:all_variable_types), id: design_options(:all_variable_types_calculated), attribute: 'units', format: 'js'
    assert_template partial: '_units'
    assert_response :success
  end

  test "should get edit variable domain" do
    xhr :get, :edit_domain, project_id: @project, design_id: designs(:all_variable_types), id: design_options(:all_variable_types_radio), format: 'js'
    assert_template partial: '_domain'
    assert_response :success
  end

  test "should create domain and add it to variable on design" do
    assert_difference('Domain.current.count') do
      patch :update_domain, project_id: @project, design_id: designs(:all_variable_types), id: design_options(:all_variable_types_radio_no_domain), domain: { name: 'new_domain_for_variable', display_name: 'New Domain For Variable', option_tokens: [ { option_index: 'new', name: 'Easy', value: '1' }, { option_index: 'new', name: 'Medium', value: '2' }, { option_index: 'new', name: 'Hard', value: '3' }, { option_index: 'new', name: 'Old Value', value: 'Value' } ] }, format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:design_option)
    assert_not_nil assigns(:domain)
    assert_equal 'new_domain_for_variable', assigns(:domain).name
    assert_equal 'New Domain For Variable', assigns(:domain).display_name
    assert_equal 4, assigns(:domain).options.size
    assert_equal assigns(:domain), assigns(:design_option).variable.domain
    assert_template 'show'
  end

  test "should update an existing domain on a design" do
    patch :update_domain, project_id: @project, design_id: designs(:sections_and_variables), id: design_options(:sections_and_variables_dropdown), domain: { name: 'dropdown_options_new', display_name: 'New Domain For Dropdown Variable', option_tokens: [ { option_index: 'new', name: 'Easy', value: '1' }, { option_index: 'new', name: 'Medium', value: '2' }, { option_index: 'new', name: 'Hard', value: '3' }, { option_index: 'new', name: 'Old Value', value: 'Value' } ] }, position: 3, variable_id: variables(:dropdown).id, update: 'domain', format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:design_option)
    assert_not_nil assigns(:domain)
    assert_equal 'dropdown_options_new', assigns(:design_option).variable.domain.name
    assert_equal 'Easy', assigns(:design_option).variable.domain.options[0][:name]
    assert_equal '1', assigns(:design_option).variable.domain.options[0][:value]
    assert_equal 'Medium', assigns(:design_option).variable.domain.options[1][:name]
    assert_equal '2', assigns(:design_option).variable.domain.options[1][:value]
    assert_equal 'Hard', assigns(:design_option).variable.domain.options[2][:name]
    assert_equal '3', assigns(:design_option).variable.domain.options[2][:value]
    assert_template 'show'
  end

  test "should update an existing domain on a design and fill in missing values" do
    patch :update_domain, project_id: @project, design_id: designs(:sections_and_variables), id: design_options(:sections_and_variables_dropdown), domain: { name: 'dropdown_options_new', display_name: 'New Domain For Dropdown Variable', option_tokens: [ { option_index: 'new', name: 'Easy', value: '' }, { option_index: 'new', name: 'Medium', value: '' }, { option_index: 'new', name: 'Hard', value: '' }, { option_index: 'new', name: 'Old Value', value: 'Value' } ] }, position: 3, variable_id: variables(:dropdown).id, update: 'domain', format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:design_option)
    assert_not_nil assigns(:domain)
    assert_equal 'dropdown_options_new', assigns(:design_option).variable.domain.name
    assert_equal 'Easy', assigns(:design_option).variable.domain.options[0][:name]
    assert_equal '1', assigns(:design_option).variable.domain.options[0][:value]
    assert_equal 'Medium', assigns(:design_option).variable.domain.options[1][:name]
    assert_equal '2', assigns(:design_option).variable.domain.options[1][:value]
    assert_equal 'Hard', assigns(:design_option).variable.domain.options[2][:name]
    assert_equal '3', assigns(:design_option).variable.domain.options[2][:value]
    assert_template 'show'
  end

  test "should not update an existing domain with blank name on a design" do
    patch :update_domain, project_id: @project, design_id: designs(:sections_and_variables), id: design_options(:sections_and_variables_dropdown), domain: { name: '', display_name: 'New Domain For Dropdown Variable', option_tokens: [ { option_index: 'new', name: 'Easy', value: '1' }, { option_index: 'new', name: 'Medium', value: '2' }, { option_index: 'new', name: 'Hard', value: '3' }, { option_index: 'new', name: 'Old Value', value: 'Value' } ] }, position: 3, variable_id: variables(:dropdown).id, update: 'domain', format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:design_option)
    assert_not_nil assigns(:domain)
    assert assigns(:domain).errors.size > 0
    assert_equal ["can't be blank", "is invalid"], assigns(:domain).errors[:name]
    assert_template 'edit_domain'
  end

  test "should create section on design" do
    assert_difference('DesignOption.count') do
      assert_difference('Section.count') do
        post :create_section, project_id: @project, design_id: @design, design_option: { position: 0 }, section: { name: 'Section A', description: 'Section Description', sub_section: '1' }, format: 'js'
      end
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:design_option)
    assert_not_nil assigns(:section)
    assert_equal 'Section A', assigns(:design_option).section.name
    assert_equal 'Section Description', assigns(:design_option).section.description
    assert_equal true, assigns(:design_option).section.sub_section?
    assert_template 'index'
  end

  test "should not create section with blank name on design" do
    assert_difference('DesignOption.count', 0) do
      assert_difference('Section.count', 0) do
        post :create_section, project_id: @project, design_id: @design, design_option: { position: 0 }, section: { name: '', description: 'Section Description', sub_section: '1' }, format: 'js'
      end
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:design_option)
    assert_not_nil assigns(:section)
    assert assigns(:section).errors.size > 0
    assert_equal ["can't be blank"], assigns(:section).errors[:name]
    assert_template 'new_section'
  end

  test "should create variable on design" do
    assert_difference('DesignOption.count') do
      assert_difference('Variable.current.count') do
        post :create_variable, project_id: @project, design_id: @design, design_option: { position: 0 }, variable: { display_name: 'My New Variable', name: 'my_new_variable', variable_type: 'string' }, format: 'js'
      end
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:design_option)
    assert_not_nil assigns(:variable)
    assert_equal 'my_new_variable', assigns(:design_option).variable.name
    assert_equal 'My New Variable', assigns(:design_option).variable.display_name
    assert_equal 'string', assigns(:design_option).variable.variable_type
    assert_template 'index'
  end

  test "should not create variable with blank name on design" do
    assert_difference('DesignOption.count', 0) do
      assert_difference('Variable.current.count', 0) do
        post :create_variable, project_id: @project, design_id: @design, design_option: { position: 0 }, variable: { display_name: '', name: 'my_new_variable', variable_type: 'string' }, format: 'js'
      end
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:design_option)
    assert_not_nil assigns(:variable)
    assert assigns(:variable).errors.size > 0
    assert_equal ["can't be blank"], assigns(:variable).errors[:display_name]
    assert_template 'new_variable'
  end

  test "should create grid variable with questions on design" do
    assert_difference('DesignOption.count') do
      assert_difference('Variable.current.count', 2) do
        post :create_variable, project_id: @project, design_id: @design, design_option: { position: 0 }, variable: { display_name: 'My New Grid Variable', name: 'my_new_grid_variable', variable_type: 'grid', questions: [ { "question_name" => 'Enter your address:', "question_type" => 'string' } ] }, format: 'js'
      end
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:design_option)
    assert_not_nil assigns(:variable)
    assert_equal 'my_new_grid_variable', assigns(:design_option).variable.name
    assert_equal 'My New Grid Variable', assigns(:design_option).variable.display_name
    assert_equal 'grid', assigns(:design_option).variable.variable_type
    assert_equal 'enter_your_address', assigns(:project).variables.find(assigns(:design_option).variable.grid_variable_ids.first).name
    assert_template 'index'
  end

  test "should create existing variable on design" do
    assert_difference('DesignOption.count') do
      assert_difference('Variable.current.count', 0) do
        post :create_existing_variable, project_id: @project, design_id: @design, design_option: { position: 0, variable_id: variables(:gender).id }, format: 'js'
      end
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:design_option)
    assert_equal 'gender_for_report', assigns(:design_option).variable.name
    assert_equal 'Gender', assigns(:design_option).variable.display_name
    assert_equal 'radio', assigns(:design_option).variable.variable_type
    assert_template 'index'
  end

  test "should not create duplicate existing variable on design" do
    assert_difference('DesignOption.count', 0) do
      assert_difference('Variable.current.count', 0) do
        post :create_existing_variable, project_id: @project, design_id: @design, design_option: { position: 0, variable_id: variables(:one).id }, format: 'js'
      end
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:design_option)
    assert_template 'new_existing_variable'
  end

  test "should update existing section on design" do
    patch :update, project_id: @project, design_id: designs(:sections_and_variables), id: design_options(:sections_and_variables_sectiona), design_option: { branching_logic: '1 = 1', required: 'required' }, section: { name: 'Section A Updated', description: 'Section Description', sub_section: '1' }, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:design_option)
    assert_equal '1 = 1', assigns(:design_option).branching_logic
    assert_equal 'required', assigns(:design_option).required
    assert_equal 'Section A Updated', assigns(:design_option).section.name
    assert_equal 'Section Description', assigns(:design_option).section.description
    assert_equal true, assigns(:design_option).section.sub_section?
    assert_template 'show'
  end

  test "should update existing variable on design" do
    patch :update, project_id: @project, design_id: designs(:sections_and_variables), id: design_options(:sections_and_variables_dropdown), design_option: { branching_logic: '1 = 1', required: 'required' }, variable: { name: "var_gender_updated", display_name: "Gender Updated" }, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:design_option)
    assert_equal '1 = 1', assigns(:design_option).branching_logic
    assert_equal 'required', assigns(:design_option).required
    assert_equal 'var_gender_updated', assigns(:design_option).variable.name
    assert_equal "Gender Updated", assigns(:design_option).variable.display_name
    assert_template 'show'
  end

  test "should not update an existing variable with a blank name on a design" do
    patch :update, project_id: @project, design_id: designs(:sections_and_variables), id: design_options(:sections_and_variables_dropdown), design_option: { branching_logic: '', required: '' }, variable: { name: "" }, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:design_option)
    assert assigns(:design_option).variable.errors.size > 0
    assert_equal ["can't be blank", "is invalid"], assigns(:design_option).variable.errors[:name]
    assert_template 'edit'
  end

  test "should remove section from design" do
    assert_difference('DesignOption.count', -1) do
      assert_difference('Section.count', -1) do
        xhr :delete, :destroy, project_id: @project, design_id: designs(:sections_and_variables), id: design_options(:sections_and_variables_sectiona), format: 'js'
      end
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:design_option)
    assert_template 'index'
    assert_response :success
  end

  test "should remove variable from design" do
    assert_difference('DesignOption.count', -1) do
      xhr :delete, :destroy, project_id: @project, design_id: designs(:sections_and_variables), id: design_options(:sections_and_variables_dropdown), format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:design_option)
    assert_template 'index'
    assert_response :success
  end

  test "should reorder options" do
    post :update_option_order, project_id: @project, design_id: @design, rows: "1,0,2", format: 'js'
    assert_not_nil assigns(:design)
    assert_equal [ActiveRecord::FixtureSet.identify(:two), ActiveRecord::FixtureSet.identify(:one), ActiveRecord::FixtureSet.identify(:date)], assigns(:design).design_options.pluck(:variable_id)
    assert_template 'update_order'
  end

  test "should reorder sections" do
    post :update_section_order, project_id: @project, design_id: designs(:sections_and_variables), sections: "1,0", format: 'js'
    assert_not_nil assigns(:design)
    assert_equal [
                    ActiveRecord::FixtureSet.identify(:date),
                    ActiveRecord::FixtureSet.identify(:sectionb),
                    ActiveRecord::FixtureSet.identify(:string),
                    ActiveRecord::FixtureSet.identify(:text),
                    ActiveRecord::FixtureSet.identify(:integer),
                    ActiveRecord::FixtureSet.identify(:numeric),
                    ActiveRecord::FixtureSet.identify(:file),
                    ActiveRecord::FixtureSet.identify(:sectiona),
                    ActiveRecord::FixtureSet.identify(:dropdown),
                    ActiveRecord::FixtureSet.identify(:checkbox),
                    ActiveRecord::FixtureSet.identify(:radio)
                 ], assigns(:design).design_options.collect{|design_option| design_option.section ? design_option.section_id : design_option.variable_id }
    assert_template 'update_order'
  end

  test "should reorder sections (keep same order)" do
    post :update_section_order, project_id: @project, design_id: designs(:sections_and_variables), sections: "0,1", format: 'js'
    assert_not_nil assigns(:design)

    assert_equal [
                    ActiveRecord::FixtureSet.identify(:date),
                    ActiveRecord::FixtureSet.identify(:sectiona),
                    ActiveRecord::FixtureSet.identify(:dropdown),
                    ActiveRecord::FixtureSet.identify(:checkbox),
                    ActiveRecord::FixtureSet.identify(:radio),
                    ActiveRecord::FixtureSet.identify(:sectionb),
                    ActiveRecord::FixtureSet.identify(:string),
                    ActiveRecord::FixtureSet.identify(:text),
                    ActiveRecord::FixtureSet.identify(:integer),
                    ActiveRecord::FixtureSet.identify(:numeric),
                    ActiveRecord::FixtureSet.identify(:file)
                 ], assigns(:design).design_options.collect{|design_option| design_option.section ? design_option.section_id : design_option.variable_id }
    assert_template 'update_order'
  end

  test "should not reorder sections with different section count" do
    post :update_section_order, project_id: @project, design_id: designs(:sections_and_variables), sections: "1", format: 'js'
    assert_not_nil assigns(:design)
    assert_equal [
                ActiveRecord::FixtureSet.identify(:date),
                ActiveRecord::FixtureSet.identify(:sectiona),
                ActiveRecord::FixtureSet.identify(:dropdown),
                ActiveRecord::FixtureSet.identify(:checkbox),
                ActiveRecord::FixtureSet.identify(:radio),
                ActiveRecord::FixtureSet.identify(:sectionb),
                ActiveRecord::FixtureSet.identify(:string),
                ActiveRecord::FixtureSet.identify(:text),
                ActiveRecord::FixtureSet.identify(:integer),
                ActiveRecord::FixtureSet.identify(:numeric),
                ActiveRecord::FixtureSet.identify(:file)
             ], assigns(:design).design_options.collect{|design_option| design_option.section ? design_option.section_id : design_option.variable_id }
    assert_template 'update_order'
  end

  test "should not reorder for invalid design" do
    login(users(:site_one_viewer))
    post :update_section_order, project_id: @project, design_id: designs(:sections_and_variables), sections: "0,1", format: 'js'
    assert_nil assigns(:design)
    assert_response :success
  end

end
