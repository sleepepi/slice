require 'test_helper'

class RandomizationSchemesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @randomization_scheme = randomization_schemes(:one)
  end

  test "should get randomize subject for published scheme" do
    get :randomize_subject, project_id: @project, id: @randomization_scheme
    assert_not_nil assigns(:randomization_scheme)
    assert_not_nil assigns(:randomization)
    assert_response :success
  end

  test "should not get randomize subject for draft scheme" do
    get :randomize_subject, project_id: @project, id: randomization_schemes(:two)
    assert_not_nil assigns(:project)
    assert_nil assigns(:randomization_scheme)
    assert_redirected_to project_randomization_schemes_path(assigns(:project))
  end

  test "should get randomize subject for published scheme with no lists" do
    post :randomize_subject_to_list, project_id: projects(:two), id: randomization_schemes(:three)
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:randomization_scheme)
    assert_response :success
  end

  test "should randomize subject for published scheme to list" do
    # Stratification Factors { "Gender" => "Male", "Age" => "< 40" }
    assert_difference('RandomizationCharacteristic.count', 2) do
      post :randomize_subject_to_list, project_id: @project, id: @randomization_scheme, subject_code: "Code02", stratification_factors: { "#{ActiveRecord::FixtureSet.identify(:gender)}" => "#{ActiveRecord::FixtureSet.identify(:male)}", "#{ActiveRecord::FixtureSet.identify(:age)}" => "#{ActiveRecord::FixtureSet.identify(:ltforty)}" }, attested: "1"
    end
    assert_not_nil assigns(:randomization_scheme)
    assert_not_nil assigns(:randomization)
    assert_redirected_to [assigns(:project), assigns(:randomization)]
  end

  test "should randomize subject for published minimization scheme to list" do
    # Stratification Factors { "Gender" => "Male", "Site" => "Two" }
    assert_difference('Randomization.count', 1) do
      assert_difference('RandomizationCharacteristic.count', 2) do
        post :randomize_subject_to_list, project_id: projects(:two), id: randomization_schemes(:minimization_with_lists), subject_code: "2TWO02", stratification_factors: { "#{ActiveRecord::FixtureSet.identify(:gender_with_lists)}" => "#{ActiveRecord::FixtureSet.identify(:male_min_with_lists)}", "#{ActiveRecord::FixtureSet.identify(:by_site_with_lists)}" => "#{ActiveRecord::FixtureSet.identify(:site_on_project_two)}" }, attested: "1"
      end
    end
    assert_not_nil assigns(:randomization_scheme)
    assert_not_nil assigns(:randomization)
    assert_equal 0, assigns(:randomization).dice_roll_cutoff
    assert_equal [{ name: treatment_arms(:ongoing_a).name, id: treatment_arms(:ongoing_a).id }], assigns(:randomization).weighted_eligible_arms
    assert_equal treatment_arms(:ongoing_a), assigns(:randomization).treatment_arm
    assert_redirected_to [assigns(:project), assigns(:randomization)]
  end

  test "should not randomize subject for to another site" do
    # Stratification Factors { "Gender" => "Male", "Site" => "One" }
    assert_difference('Randomization.count', 0) do
      assert_difference('RandomizationCharacteristic.count', 0) do
        post :randomize_subject_to_list, project_id: projects(:two), id: randomization_schemes(:minimization_with_lists), subject_code: "2TWO02", stratification_factors: { "#{ActiveRecord::FixtureSet.identify(:gender_with_lists)}" => "#{ActiveRecord::FixtureSet.identify(:male_min_with_lists)}", "#{ActiveRecord::FixtureSet.identify(:by_site_with_lists)}" => "#{ActiveRecord::FixtureSet.identify(:two)}" }, attested: "1"
      end
    end
    assert_not_nil assigns(:randomization_scheme)
    assert_not_nil assigns(:randomization)
    assert assigns(:randomization).errors.size > 0
    assert_equal ["must be randomized to their site"], assigns(:randomization).errors[:subject_id]
    assert_response :success
  end

  test "should randomize subject for fully random minimization scheme to list" do
    # Stratification Factors { "Gender" => "Male" }
    assert_difference('Randomization.count', 1) do
      assert_difference('RandomizationCharacteristic.count', 1) do
        post :randomize_subject_to_list, project_id: projects(:two), id: randomization_schemes(:fully_random_minimization), subject_code: "2TWO02", stratification_factors: { "#{ActiveRecord::FixtureSet.identify(:gender_random)}" => "#{ActiveRecord::FixtureSet.identify(:male_random)}" }, attested: "1"
      end
    end
    assert_not_nil assigns(:randomization_scheme)
    assert_not_nil assigns(:randomization)
    assert_equal 100, assigns(:randomization).dice_roll_cutoff
    assert_equal [{ name: treatment_arms(:random_a).name, id: treatment_arms(:random_a).id }, { name: treatment_arms(:random_b).name, id: treatment_arms(:random_b).id }, { name: treatment_arms(:random_b).name, id: treatment_arms(:random_b).id }], assigns(:randomization).weighted_eligible_arms
    assert_redirected_to [assigns(:project), assigns(:randomization)]
  end

  test "should not randomize subject for minimization scheme without all criteria selected" do
    # Stratification Factors { "Gender" => "Male" }
    assert_difference('Randomization.count', 0) do
      assert_difference('RandomizationCharacteristic.count', 0) do
        post :randomize_subject_to_list, project_id: projects(:two), id: randomization_schemes(:minimization_with_lists), subject_code: "2TWO02", stratification_factors: { "#{ActiveRecord::FixtureSet.identify(:gender_with_lists)}" => "#{ActiveRecord::FixtureSet.identify(:male_min_with_lists)}" }, attested: "1"
      end
    end
    assert_not_nil assigns(:randomization_scheme)
    assert_not_nil assigns(:randomization)
    assert assigns(:randomization).errors.size > 0
    assert_equal ["can't be blank"], assigns(:randomization).errors[:stratification_factors]
    assert_response :success
  end

  test "should not randomize subject to list if already randomized" do
    post :randomize_subject_to_list, project_id: @project, id: @randomization_scheme, subject_code: "Code01", stratification_factors: { "#{ActiveRecord::FixtureSet.identify(:gender)}" => "#{ActiveRecord::FixtureSet.identify(:male)}", "#{ActiveRecord::FixtureSet.identify(:age)}" => "#{ActiveRecord::FixtureSet.identify(:ltforty)}" }, attested: "1"
    assert_not_nil assigns(:randomization_scheme)
    assert_not_nil assigns(:randomization)
    assert assigns(:randomization).errors.size > 0
    assert_equal ["has already been randomized"], assigns(:randomization).errors[:subject_id]
    assert_response :success
  end

  test "should not randomize subject to list if subject code is blank" do
    post :randomize_subject_to_list, project_id: @project, id: @randomization_scheme, subject_code: "", stratification_factors: { "#{ActiveRecord::FixtureSet.identify(:gender)}" => "#{ActiveRecord::FixtureSet.identify(:male)}", "#{ActiveRecord::FixtureSet.identify(:age)}" => "#{ActiveRecord::FixtureSet.identify(:ltforty)}" }, attested: "1"
    assert_not_nil assigns(:randomization_scheme)
    assert_not_nil assigns(:randomization)
    assert assigns(:randomization).errors.size > 0
    assert_equal ["can't be blank"], assigns(:randomization).errors[:subject_code]
    assert_response :success
  end

  test "should not randomize subject to list if missing one or more stratification factors" do
    post :randomize_subject_to_list, project_id: @project, id: @randomization_scheme, subject_code: "Code02", stratification_factors: { "#{ActiveRecord::FixtureSet.identify(:gender)}" => "#{ActiveRecord::FixtureSet.identify(:male)}" }, attested: "1"
    assert_not_nil assigns(:randomization_scheme)
    assert_not_nil assigns(:randomization)
    assert assigns(:randomization).errors.size > 0
    assert_equal ["can't be blank"], assigns(:randomization).errors[:stratification_factors]
    assert_response :success
  end

  test "should not randomize subject to list if missing all stratification factors" do
    post :randomize_subject_to_list, project_id: @project, id: @randomization_scheme, subject_code: "Code02", attested: "1"
    assert_not_nil assigns(:randomization_scheme)
    assert_not_nil assigns(:randomization)
    assert assigns(:randomization).errors.size > 0
    assert_equal ["can't be blank"], assigns(:randomization).errors[:stratification_factors]
    assert_response :success
  end

  test "should not randomize subject to list if attestation is not checked" do
    post :randomize_subject_to_list, project_id: @project, id: @randomization_scheme, subject_code: "Code02", stratification_factors: { "#{ActiveRecord::FixtureSet.identify(:gender)}" => "#{ActiveRecord::FixtureSet.identify(:male)}", "#{ActiveRecord::FixtureSet.identify(:age)}" => "#{ActiveRecord::FixtureSet.identify(:ltforty)}" }, attested: "0"
    assert_not_nil assigns(:randomization_scheme)
    assert_not_nil assigns(:randomization)
    assert assigns(:randomization).errors.size > 0
    assert_equal ["must be checked"], assigns(:randomization).errors[:attested]
    assert_response :success
  end

  test "should not randomize subject if no lists have been generated for randomization scheme" do
    post :randomize_subject_to_list, project_id: projects(:two), id: randomization_schemes(:three), subject_code: "2TWO02", stratification_factors: { }, attested: "1"
    assert_not_nil assigns(:randomization_scheme)
    assert_not_nil assigns(:randomization)
    assert assigns(:randomization).errors.size > 0
    assert_equal ["need to be generated before a subject can be randomized"], assigns(:randomization).errors[:lists]
    assert_response :success
  end

  test "should not randomize subject to list for draft scheme" do
    post :randomize_subject_to_list, project_id: @project, id: randomization_schemes(:two)
    assert_not_nil assigns(:project)
    assert_nil assigns(:randomization_scheme)
    assert_redirected_to project_randomization_schemes_path(assigns(:project))
  end

  test "should get index" do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:randomization_schemes)
  end

  test "should get new" do
    get :new, project_id: @project
    assert_response :success
  end

  test "should create randomization_scheme" do
    assert_difference('RandomizationScheme.count') do
      post :create, project_id: @project, randomization_scheme: { name: "New Randomization Scheme", description: @randomization_scheme.description, published: @randomization_scheme.published, randomization_goal: @randomization_scheme.randomization_goal }
    end

    assert_redirected_to project_randomization_scheme_path(assigns(:project), assigns(:randomization_scheme))
  end

  test "should not create randomization scheme with blank name" do
    assert_difference('RandomizationScheme.count', 0) do
      post :create, project_id: @project, randomization_scheme: { name: "", description: @randomization_scheme.description, published: @randomization_scheme.published, randomization_goal: @randomization_scheme.randomization_goal }
    end
    assert_not_nil assigns(:randomization_scheme)
    assert assigns(:randomization_scheme).errors.size > 0
    assert_equal ["can't be blank"], assigns(:randomization_scheme).errors[:name]
    assert_template 'new'
    assert_response :success
  end

  test "should show randomization_scheme" do
    get :show, project_id: @project, id: @randomization_scheme
    assert_response :success
  end

  test "should get edit" do
    get :edit, project_id: @project, id: @randomization_scheme
    assert_response :success
  end

  test "should update randomization_scheme" do
    patch :update, project_id: @project, id: @randomization_scheme, randomization_scheme: { name: "Updated Randomization Scheme", description: @randomization_scheme.description, published: @randomization_scheme.published, randomization_goal: @randomization_scheme.randomization_goal }
    assert_redirected_to project_randomization_scheme_path(assigns(:project), assigns(:randomization_scheme))
  end

  test "should not update randomization scheme with existing name" do
    patch :update, project_id: @project, id: @randomization_scheme, randomization_scheme: { name: "Randomization Scheme 2", description: @randomization_scheme.description, published: @randomization_scheme.published, randomization_goal: @randomization_scheme.randomization_goal }
    assert_not_nil assigns(:randomization_scheme)
    assert assigns(:randomization_scheme).errors.size > 0
    assert_equal ["has already been taken"], assigns(:randomization_scheme).errors[:name]
    assert_template 'edit'
    assert_response :success
  end

  test "should destroy randomization_scheme" do
    assert_difference('RandomizationScheme.current.count', -1) do
      delete :destroy, project_id: @project, id: @randomization_scheme
    end

    assert_redirected_to project_randomization_schemes_path(assigns(:project))
  end
end
