# frozen_string_literal: true

require "test_helper"

# Assure that project editors can view and modify randomization schemes.
class RandomizationSchemesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_one_editor = users(:project_one_editor)
    @project_viewer = users(:project_one_viewer)
    @site_editor = users(:site_one_editor)
    @site_viewer = users(:site_one_viewer)

    @project_two_editor = users(:regular)

    @project = projects(:one)
    @randomization_scheme = randomization_schemes(:one)
  end

  def randomization_scheme_params
    {
      name: "New Randomization Scheme",
      description: @randomization_scheme.description,
      randomization_goal: @randomization_scheme.randomization_goal
    }
  end

  test "should get randomize subject for published scheme" do
    login(@project_one_editor)
    get randomize_subject_project_randomization_scheme_url(@project, @randomization_scheme)
    assert_response :success
  end

  test "should get randomize subject for published scheme for site editor" do
    login(@site_editor)
    get randomize_subject_project_randomization_scheme_url(@project, @randomization_scheme)
    assert_response :success
  end

  test "should not get randomize subject for published scheme for site viewer" do
    login(@site_viewer)
    get randomize_subject_project_randomization_scheme_url(@project, @randomization_scheme)
    assert_redirected_to root_url
  end

  test "should not get randomize subject for draft scheme" do
    login(@project_one_editor)
    get randomize_subject_project_randomization_scheme_url(@project, randomization_schemes(:two))
    assert_redirected_to project_randomization_schemes_url(@project)
  end

  test "should get subject search as project editor" do
    login(@project_one_editor)
    get subject_search_project_randomization_scheme_url(@project, @randomization_scheme), params: { q: "Code01" }
    subjects_json = JSON.parse(response.body)
    assert_equal "Code01", subjects_json.first["value"]
    assert_equal "Code01", subjects_json.first["subject_code"]
    assert_equal "R", subjects_json.first["status"]
    assert_response :success
  end

  test "should get subject search and display subject as ineligible for randomization" do
    login(@project_two_editor)
    get subject_search_project_randomization_scheme_url(
      projects(:two),
      randomization_schemes(:minimization_with_required_variable)
    ), params: {
      q: "2TWO02"
    }
    subjects_json = JSON.parse(response.body)
    assert_equal "2TWO02", subjects_json.first["value"]
    assert_equal "2TWO02", subjects_json.first["subject_code"]
    assert_equal "I", subjects_json.first["status"]
    assert_response :success
  end

  test "should get randomize subject for published scheme with no lists" do
    login(@project_two_editor)
    post randomize_subject_to_list_project_randomization_scheme_url(
      projects(:two), randomization_schemes(:three)
    )
    assert_response :success
  end

  test "should randomize subject for published scheme to list" do
    login(@project_one_editor)
    # Stratification Factors { "Gender" => "Male", "Age" => "< 40" }
    assert_difference("RandomizationCharacteristic.count", 2) do
      post randomize_subject_to_list_project_randomization_scheme_url(
        @project, @randomization_scheme
      ), params: {
        subject_code: "Code02",
        stratification_factors: {
          ActiveRecord::FixtureSet.identify(:gender).to_s => ActiveRecord::FixtureSet.identify(:male).to_s,
          ActiveRecord::FixtureSet.identify(:age).to_s => ActiveRecord::FixtureSet.identify(:ltforty).to_s
        },
        attested: "1"
      }
    end
    assert_redirected_to [assigns(:project), assigns(:randomization)]
  end

  test "should randomize subject for published scheme to list as site editor" do
    login(@site_editor)
    # Stratification Factors { "Gender" => "Male", "Age" => "< 40" }
    assert_difference("RandomizationCharacteristic.count", 2) do
      post randomize_subject_to_list_project_randomization_scheme_url(
        @project, @randomization_scheme
      ), params: {
        subject_code: "Code02",
        stratification_factors: {
          ActiveRecord::FixtureSet.identify(:gender).to_s => ActiveRecord::FixtureSet.identify(:male).to_s,
          ActiveRecord::FixtureSet.identify(:age).to_s => ActiveRecord::FixtureSet.identify(:ltforty).to_s
        },
        attested: "1"
      }
    end
    assert_redirected_to [assigns(:project), assigns(:randomization)]
  end

  test "should not randomize subject on another site as the site editor" do
    login(@site_editor)
    # Stratification Factors { "Gender" => "Male", "Age" => "< 40" }
    assert_difference("RandomizationCharacteristic.count", 0) do
      post randomize_subject_to_list_project_randomization_scheme_url(
        @project, @randomization_scheme
      ), params: {
        subject_code: "S2001",
        stratification_factors: {
          ActiveRecord::FixtureSet.identify(:gender).to_s => ActiveRecord::FixtureSet.identify(:male).to_s,
          ActiveRecord::FixtureSet.identify(:age).to_s => ActiveRecord::FixtureSet.identify(:ltforty).to_s
        },
        attested: "1"
      }
    end
    assert_equal ["does not match an existing subject"], assigns(:randomization).errors[:subject_code]
    assert_response :success
  end

  test "should not randomize subject for published scheme to list as site viewer" do
    login(@site_viewer)
    # Stratification Factors { "Gender" => "Male", "Age" => "< 40" }
    assert_difference("RandomizationCharacteristic.count", 0) do
      post randomize_subject_to_list_project_randomization_scheme_url(
        @project, @randomization_scheme
      ), params: {
        subject_code: "Code02",
        stratification_factors: {
          ActiveRecord::FixtureSet.identify(:gender).to_s => ActiveRecord::FixtureSet.identify(:male).to_s,
          ActiveRecord::FixtureSet.identify(:age).to_s => ActiveRecord::FixtureSet.identify(:ltforty).to_s
        },
        attested: "1"
      }
    end
    assert_redirected_to root_url
  end

  test "should randomize subject for published minimization scheme to list" do
    login(@project_two_editor)
    # Stratification Factors { "Gender" => "Male", "Site" => "Two" }
    assert_difference("Randomization.count", 1) do
      assert_difference("RandomizationCharacteristic.count", 2) do
        post randomize_subject_to_list_project_randomization_scheme_url(
          projects(:two),
          randomization_schemes(:minimization_with_lists)
        ), params: {
          subject_code: "2TWO02",
          stratification_factors: {
            ActiveRecord::FixtureSet.identify(:gender_with_lists).to_s => ActiveRecord::FixtureSet.identify(:male_min_with_lists).to_s,
            ActiveRecord::FixtureSet.identify(:by_site_with_lists).to_s => ActiveRecord::FixtureSet.identify(:site_on_project_two).to_s
          },
          attested: "1"
        }
      end
    end
    assert_equal 0, assigns(:randomization).dice_roll_cutoff
    assert_equal 1, assigns(:randomization).weighted_eligible_arms.size
    assert_equal treatment_arms(:ongoing_a).name, assigns(:randomization).weighted_eligible_arms.first[:name]
    assert_equal treatment_arms(:ongoing_a).id, assigns(:randomization).weighted_eligible_arms.first[:id]
    assert_equal treatment_arms(:ongoing_a), assigns(:randomization).treatment_arm
    assert_redirected_to [assigns(:project), assigns(:randomization)]
  end

  test "should not randomize subject for to another site" do
    login(@project_two_editor)
    # Stratification Factors { "Gender" => "Male", "Site" => "One" }
    assert_difference("Randomization.count", 0) do
      assert_difference("RandomizationCharacteristic.count", 0) do
        post randomize_subject_to_list_project_randomization_scheme_url(
          projects(:two),
          randomization_schemes(:minimization_with_lists)
        ), params: {
          subject_code: "2TWO02",
          stratification_factors: {
            ActiveRecord::FixtureSet.identify(:gender_with_lists).to_s => ActiveRecord::FixtureSet.identify(:male_min_with_lists).to_s,
            ActiveRecord::FixtureSet.identify(:by_site_with_lists).to_s => ActiveRecord::FixtureSet.identify(:two).to_s
          },
          attested: "1"
        }
      end
    end
    assert_equal ["must be randomized to their site"], assigns(:randomization).errors[:subject_id]
    assert_response :success
  end

  test "should randomize subject for fully random minimization scheme to list" do
    login(@project_two_editor)
    # Stratification Factors { "Gender" => "Male" }
    assert_difference("Randomization.count", 1) do
      assert_difference("RandomizationCharacteristic.count", 1) do
        post randomize_subject_to_list_project_randomization_scheme_url(
          projects(:two),
          randomization_schemes(:fully_random_minimization)
        ), params: {
          subject_code: "2TWO02",
          stratification_factors: {
            ActiveRecord::FixtureSet.identify(:gender_random).to_s => ActiveRecord::FixtureSet.identify(:male_random).to_s
          },
          attested: "1"
        }
      end
    end
    assert_equal 100, assigns(:randomization).dice_roll_cutoff
    assert_equal 3, assigns(:randomization).weighted_eligible_arms.size
    assert_equal treatment_arms(:random_a).name, assigns(:randomization).weighted_eligible_arms.first[:name]
    assert_equal treatment_arms(:random_a).id, assigns(:randomization).weighted_eligible_arms.first[:id]
    assert_equal treatment_arms(:random_b).name, assigns(:randomization).weighted_eligible_arms.second[:name]
    assert_equal treatment_arms(:random_b).id, assigns(:randomization).weighted_eligible_arms.second[:id]
    assert_equal treatment_arms(:random_b).name, assigns(:randomization).weighted_eligible_arms.third[:name]
    assert_equal treatment_arms(:random_b).id, assigns(:randomization).weighted_eligible_arms.third[:id]
    assert_redirected_to [assigns(:project), assigns(:randomization)]
  end

  test "should not randomize subject for minimization scheme without all criteria selected" do
    login(@project_two_editor)
    # Stratification Factors { "Gender" => "Male" }
    assert_difference("Randomization.count", 0) do
      assert_difference("RandomizationCharacteristic.count", 0) do
        post randomize_subject_to_list_project_randomization_scheme_url(
          projects(:two),
          randomization_schemes(:minimization_with_lists)
        ), params: {
          subject_code: "2TWO02",
          stratification_factors: {
            ActiveRecord::FixtureSet.identify(:gender_with_lists).to_s => ActiveRecord::FixtureSet.identify(:male_min_with_lists).to_s
          },
          attested: "1"
        }
      end
    end
    assert_equal ["can't be blank"], assigns(:randomization).errors[:stratification_factors]
    assert_response :success
  end

  test "should not randomize subject to list if already randomized" do
    login(@project_one_editor)
    post randomize_subject_to_list_project_randomization_scheme_url(
      @project, @randomization_scheme
    ), params: {
      subject_code: "Code01",
      stratification_factors: {
        ActiveRecord::FixtureSet.identify(:gender).to_s => ActiveRecord::FixtureSet.identify(:male).to_s,
        ActiveRecord::FixtureSet.identify(:age).to_s => ActiveRecord::FixtureSet.identify(:ltforty).to_s
      },
      attested: "1"
    }
    assert_equal ["has already been randomized"], assigns(:randomization).errors[:subject_id]
    assert_response :success
  end

  test "should not randomize subject to list if subject code is blank" do
    login(@project_one_editor)
    post randomize_subject_to_list_project_randomization_scheme_url(
      @project, @randomization_scheme
    ), params: {
      subject_code: "",
      stratification_factors: {
        ActiveRecord::FixtureSet.identify(:gender).to_s => ActiveRecord::FixtureSet.identify(:male).to_s,
        ActiveRecord::FixtureSet.identify(:age).to_s => ActiveRecord::FixtureSet.identify(:ltforty).to_s
      },
      attested: "1"
    }
    assert_equal ["does not match an existing subject"], assigns(:randomization).errors[:subject_code]
    assert_response :success
  end

  test "should not randomize subject to list if missing one or more stratification factors" do
    login(@project_one_editor)
    post randomize_subject_to_list_project_randomization_scheme_url(
      @project,
      @randomization_scheme
    ), params: {
      subject_code: "Code02",
      stratification_factors: {
        ActiveRecord::FixtureSet.identify(:gender).to_s => ActiveRecord::FixtureSet.identify(:male).to_s
      },
      attested: "1"
    }
    assert_equal ["can't be blank"], assigns(:randomization).errors[:stratification_factors]
    assert_response :success
  end

  test "should not randomize subject to list if missing all stratification factors" do
    login(@project_one_editor)
    post randomize_subject_to_list_project_randomization_scheme_url(
      @project,
      @randomization_scheme
    ), params: {
      subject_code: "Code02",
      attested: "1"
    }
    assert_equal ["can't be blank"], assigns(:randomization).errors[:stratification_factors]
    assert_response :success
  end

  test "should not randomize subject to list if attestation is not checked" do
    login(@project_one_editor)
    post randomize_subject_to_list_project_randomization_scheme_url(
      @project, @randomization_scheme
    ), params: {
      subject_code: "Code02",
      stratification_factors: {
        ActiveRecord::FixtureSet.identify(:gender).to_s => ActiveRecord::FixtureSet.identify(:male).to_s,
        ActiveRecord::FixtureSet.identify(:age).to_s => ActiveRecord::FixtureSet.identify(:ltforty).to_s
      },
      attested: "0"
    }
    assert_equal ["must be checked"], assigns(:randomization).errors[:attested]
    assert_response :success
  end

  test "should not randomize subject if no lists have been generated for randomization scheme" do
    login(@project_two_editor)
    post randomize_subject_to_list_project_randomization_scheme_url(
      projects(:two),
      randomization_schemes(:three)
    ), params: {
      subject_code: "2TWO02", stratification_factors: { }, attested: "1"
    }
    assert_equal ["need to be generated before a subject can be randomized"], assigns(:randomization).errors[:lists]
    assert_response :success
  end

  test "should not randomize subject to list for draft scheme" do
    login(@project_one_editor)
    post randomize_subject_to_list_project_randomization_scheme_url(
      @project, randomization_schemes(:two)
    )
    assert_redirected_to project_randomization_schemes_url(assigns(:project))
  end

  test "should randomize male to correct treatment arm for minimization scheme" do
    login(@project_two_editor)
    # Stratification Factors { "Gender" => "Male", "Site" => "Site One on Project Two" }
    assert_difference("Randomization.count", 1) do
      assert_difference("RandomizationCharacteristic.count", 2) do
        post randomize_subject_to_list_project_randomization_scheme_url(
          projects(:two),
          randomization_schemes(:minimization_for_testing_edge_case)
        ), params: {
          subject_code: "edge10",
          stratification_factors: {
            ActiveRecord::FixtureSet.identify(:edge_gender).to_s => ActiveRecord::FixtureSet.identify(:edge_male).to_s,
            ActiveRecord::FixtureSet.identify(:edge_site).to_s => ActiveRecord::FixtureSet.identify(:two).to_s
          },
          attested: "1"
        }
      end
    end
    assert_equal 0, assigns(:randomization).dice_roll_cutoff
    # Should not include site in stratification factors
    assert_equal [{ count: 1.67, treatment_arm_id: treatment_arms(:edge_a_3).id }, { count: 1.0, treatment_arm_id: treatment_arms(:edge_b_1).id }], assigns(:randomization).past_distributions[:weighted_totals]
    assert_equal treatment_arms(:edge_b_1), assigns(:randomization).treatment_arm
    assert_redirected_to [assigns(:project), assigns(:randomization)]
  end

  test "should not randomize ineligible subject to list" do
    login(@project_two_editor)
    # Stratification Factors { "Site" => "SITE ID" }
    assert_difference("RandomizationCharacteristic.count", 0) do
      post randomize_subject_to_list_project_randomization_scheme_url(
        projects(:two),
        randomization_schemes(:minimization_with_required_variable)
      ), params: {
        subject_code: "2TWO02",
        stratification_factors: {
          ActiveRecord::FixtureSet.identify(:required_variable_site).to_s => ActiveRecord::FixtureSet.identify(:site_on_project_two).to_s,
          ActiveRecord::FixtureSet.identify(:required_and_calculated).to_s => ActiveRecord::FixtureSet.identify(:required_and_calculated_one).to_s
        },
        attested: "1"
      }
    end
    assert_equal ["is ineligible for randomization due to variable criteria", "Eligible for Randomization? is not equal to 1"], assigns(:randomization).errors[:subject_id]
    assert_response :success
  end

  test "should randomize eligible subject to list" do
    login(@project_two_editor)
    # Stratification Factors { "Site" => "SITE ID" }
    assert_difference("RandomizationCharacteristic.count", 2) do
      post randomize_subject_to_list_project_randomization_scheme_url(
        projects(:two), randomization_schemes(:minimization_with_required_variable)
      ), params: {
        subject_code: "eligible_for_randomization",
        stratification_factors: {
          ActiveRecord::FixtureSet.identify(:required_variable_site).to_s => ActiveRecord::FixtureSet.identify(:site_on_project_two).to_s,
          ActiveRecord::FixtureSet.identify(:required_and_calculated).to_s => ActiveRecord::FixtureSet.identify(:required_and_calculated_one).to_s
        },
        attested: "1"
      }
    end
    assert_redirected_to [assigns(:project), assigns(:randomization)]
  end

  test "should not randomize eligible subject to list with incorrect calculated criteria" do
    login(@project_two_editor)
    # Stratification Factors { "Site" => "SITE ID" }
    assert_difference("RandomizationCharacteristic.count", 0) do
      post randomize_subject_to_list_project_randomization_scheme_url(
        projects(:two),
        randomization_schemes(:minimization_with_required_variable)
      ), params: {
        subject_code: "eligible_for_randomization",
        stratification_factors: {
          ActiveRecord::FixtureSet.identify(:required_variable_site).to_s => ActiveRecord::FixtureSet.identify(:site_on_project_two).to_s,
          ActiveRecord::FixtureSet.identify(:required_and_calculated).to_s => ActiveRecord::FixtureSet.identify(:required_and_calculated_two).to_s
        },
        attested: "1"
      }
    end
    assert_equal ["does not match value specified on subject sheet"], assigns(:randomization).errors[:calculated]
    assert_response :success
  end

  test "should get index" do
    login(@project_one_editor)
    get project_randomization_schemes_url(@project)
    assert_response :success
  end

  test "should get new" do
    login(@project_one_editor)
    get new_project_randomization_scheme_url(@project)
    assert_response :success
  end

  test "should create randomization_scheme" do
    login(@project_one_editor)
    assert_difference("RandomizationScheme.count") do
      post project_randomization_schemes_url(@project), params: {
        randomization_scheme: randomization_scheme_params
      }
    end
    assert_redirected_to project_randomization_scheme_url(assigns(:project), assigns(:randomization_scheme))
  end

  test "should not create randomization scheme with blank name" do
    login(@project_one_editor)
    assert_difference("RandomizationScheme.count", 0) do
      post project_randomization_schemes_url(@project), params: {
        randomization_scheme: randomization_scheme_params.merge(name: "")
      }
    end
    assert_equal ["can't be blank"], assigns(:randomization_scheme).errors[:name]
    assert_template "new"
    assert_response :success
  end

  test "should show randomization scheme" do
    login(@project_one_editor)
    get project_randomization_scheme_url(@project, @randomization_scheme)
    assert_response :success
  end

  test "should get edit" do
    login(@project_one_editor)
    get edit_project_randomization_scheme_url(@project, @randomization_scheme)
    assert_response :success
  end

  test "should update randomization scheme" do
    login(@project_one_editor)
    patch project_randomization_scheme_url(@project, @randomization_scheme), params: {
      randomization_scheme: randomization_scheme_params.merge(name: "Updated Randomization Scheme")
    }
    assert_redirected_to project_randomization_scheme_url(@project, @randomization_scheme)
  end

  test "should not update randomization scheme with existing name" do
    login(@project_one_editor)
    patch project_randomization_scheme_url(@project, @randomization_scheme), params: {
      randomization_scheme: randomization_scheme_params.merge(name: "Randomization Scheme 2")
    }
    assert_equal ["has already been taken"], assigns(:randomization_scheme).errors[:name]
    assert_template "edit"
    assert_response :success
  end

  test "should publish randomization scheme" do
    login(@project_one_editor)
    post publish_project_randomization_scheme_url(@project, @randomization_scheme)
    @randomization_scheme.reload
    assert_equal true, @randomization_scheme.published
    assert_redirected_to project_randomization_scheme_url(@project, @randomization_scheme)
  end

  test "should unpublish randomization scheme" do
    login(@project_two_editor)
    post unpublish_project_randomization_scheme_url(projects(:two), randomization_schemes(:three))
    randomization_schemes(:three).reload
    assert_equal false, randomization_schemes(:three).published
    assert_redirected_to project_randomization_scheme_url(projects(:two), randomization_schemes(:three))
  end

  test "should destroy randomization_scheme" do
    login(@project_one_editor)
    assert_difference("RandomizationScheme.current.count", -1) do
      delete project_randomization_scheme_url(@project, @randomization_scheme)
    end
    assert_redirected_to project_randomization_schemes_url(assigns(:project))
  end

  test "should get edit randomization" do
    login(users(:custom_randomizations_editor))
    get edit_randomization_project_randomization_scheme_url(
      projects(:custom_randomizations),
      randomization_schemes(:custom_randomizations),
      randomizations(:custom_two)
    )
    assert_response :success
  end

  test "should not edit assigned randomization" do
    login(users(:custom_randomizations_editor))
    get edit_randomization_project_randomization_scheme_url(
      projects(:custom_randomizations),
      randomization_schemes(:custom_randomizations),
      randomizations(:custom_one)
    )
    assert_redirected_to project_randomization_scheme_url(
      projects(:custom_randomizations), randomization_schemes(:custom_randomizations)
    )
  end

  test "should update randomization" do
    login(users(:custom_randomizations_editor))
    patch update_randomization_project_randomization_scheme_url(
      projects(:custom_randomizations),
      randomization_schemes(:custom_randomizations),
      randomizations(:custom_two)
    ), params: {
      randomization: { custom_treatment_name: "Device #B001 - Backup" }
    }
    assert_redirected_to project_randomization_scheme_url(
      projects(:custom_randomizations), randomization_schemes(:custom_randomizations)
    )
  end

  test "should not update randomization with blank treatment name" do
    login(users(:custom_randomizations_editor))
    patch update_randomization_project_randomization_scheme_url(
      projects(:custom_randomizations),
      randomization_schemes(:custom_randomizations),
      randomizations(:custom_two)
    ), params: {
      randomization: { custom_treatment_name: "" }
    }
    assert_template "edit_randomization"
    assert_response :success
  end

  test "should not update assigned randomization" do
    login(users(:custom_randomizations_editor))
    patch update_randomization_project_randomization_scheme_url(
      projects(:custom_randomizations),
      randomization_schemes(:custom_randomizations),
      randomizations(:custom_one)
    ), params: {
      randomization: { custom_treatment_name: "Device #5001 - Rename" }
    }
    randomizations(:custom_one).reload
    assert_equal "Device #5001", randomizations(:custom_one).custom_treatment_name
    assert_redirected_to project_randomization_scheme_url(
      projects(:custom_randomizations), randomization_schemes(:custom_randomizations)
    )
  end

  test "should destroy randomization" do
    login(users(:custom_randomizations_editor))
    assert_difference("Randomization.current.count", -1) do
      delete destroy_randomization_project_randomization_scheme_url(
        projects(:custom_randomizations),
        randomization_schemes(:custom_randomizations),
        randomizations(:custom_four)
      )
    end
    assert_redirected_to project_randomization_scheme_url(
      projects(:custom_randomizations), randomization_schemes(:custom_randomizations)
    )
  end

  test "should not destroy assigned randomization" do
    login(users(:custom_randomizations_editor))
    assert_difference("Randomization.current.count", 0) do
      delete destroy_randomization_project_randomization_scheme_url(
        projects(:custom_randomizations),
        randomization_schemes(:custom_randomizations),
        randomizations(:custom_one)
      )
    end
    assert_redirected_to project_randomization_scheme_url(
      projects(:custom_randomizations), randomization_schemes(:custom_randomizations)
    )
  end
end
