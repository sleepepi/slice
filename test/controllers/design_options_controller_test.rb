require 'test_helper'

class DesignOptionsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @design = designs(:one)
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
