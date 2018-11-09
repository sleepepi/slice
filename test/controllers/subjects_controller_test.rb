# frozen_string_literal: true

require "test_helper"

# Tests to assure that project and site editors can create and modify subjects.
class SubjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    @subject = subjects(:one)
    @project_editor = users(:project_one_editor)
    @project_viewer = users(:project_one_viewer)
    @site_editor = users(:site_one_editor)
    @site_viewer = users(:site_one_viewer)
  end

  test "should update event coverage" do
    login(@site_viewer)
    post event_coverage_project_subject_url(@project, @subject, format: "js"), params: {
      subject_event_id: subject_events(:one).id
    }
    assert_template "subject_events/coverage"
    assert_response :success
  end

  test "should get autocomplete as site viewer" do
    login(@site_viewer)
    get autocomplete_project_subjects_url(@project), params: { q: "Code" }
    assert_response :success
  end

  test "should get designs search" do
    login(@site_viewer)
    get designs_search_project_subjects_url(@project, format: "json"), params: {
      q: "designs:"
    }, xhr: true
    assert_response :success
  end

  test "should get events search" do
    login(@site_viewer)
    get events_search_project_subjects_url(@project, format: "json"), params: {
      q: "events:"
    }, xhr: true
    assert_response :success
  end

  test "should get data entry as site editor" do
    login(users(:site_one_editor))
    get data_entry_project_subject_url(@project, @subject)
    assert_response :success
  end

  test "should not get data entry as site viewer" do
    login(users(:site_one_viewer))
    get data_entry_project_subject_url(@project, @subject)
    assert_redirected_to root_url
  end

  test "should get new data entry as site editor" do
    login(users(:site_one_editor))
    get new_data_entry_project_subject_url(@project, @subject, design_id: designs(:all_variable_types).id)
    assert_equal designs(:all_variable_types), assigns(:sheet).design
    assert_response :success
  end

  test "should not get new data entry as site viewer" do
    login(users(:site_one_viewer))
    get new_data_entry_project_subject_url(@project, @subject, design_id: designs(:all_variable_types).id)
    assert_redirected_to root_url
  end

  test "should not get data entry new with invalid design" do
    login(users(:site_one_editor))
    get new_data_entry_project_subject_url(@project, @subject, design_id: -1)
    assert_redirected_to data_entry_project_subject_url(@project, @subject)
  end

  test "should set sheet as missing on subject event as site editor" do
    login(users(:site_one_editor))
    assert_difference("Sheet.current.where(missing: true).count", 1) do
      post set_sheet_as_missing_project_subject_url(
        @project,
        @subject,
        design_id: designs(:all_variable_types).id,
        subject_event_id: subject_events(:one).id,
        format: "js"
      )
    end
    assert_equal users(:site_one_editor), assigns(:sheet).user
    assert_equal users(:site_one_editor), assigns(:sheet).last_user
    assert_not_nil assigns(:sheet).last_edited_at
    assert_template "sheets/subject_event"
    assert_response :success
  end

  test "should get send url as site editor" do
    login(@site_editor)
    get send_url_project_subject_url(@project, @subject)
    assert_response :success
  end

  test "should set sheet as shareable as site editor" do
    login(@site_editor)
    assert_difference("Sheet.count") do
      post set_sheet_as_shareable_project_subject_url(@project, @subject), params: {
        design_id: designs(:sections_and_variables).id,
        subject_event_id: subject_events(:one).id
      }
    end
    assert_not_nil Sheet.last.last_edited_at
    assert_redirected_to [@project, Sheet.last]
  end

  test "should get search as project editor" do
    login(@project_editor)
    get search_project_subjects_url(@project), params: { q: "Code01" }
    subjects_json = JSON.parse(response.body)
    assert_equal "Code01", subjects_json.first["value"]
    assert_equal "Code01", subjects_json.first["subject_code"]
    assert_response :success
  end

  test "should get search as project viewer" do
    login(@project_viewer)
    get search_project_subjects_url(@project), params: { q: "Code01" }
    subjects_json = JSON.parse(response.body)
    assert_equal "Code01", subjects_json.first["value"]
    assert_equal "Code01", subjects_json.first["subject_code"]
    assert_response :success
  end

  test "should search and return no subjects found for new subject" do
    login(@project_editor)
    get search_project_subjects_url(@project), params: { q: "NewCode" }
    subjects_json = JSON.parse(response.body)
    assert_equal "NewCode", subjects_json.first["value"]
    assert_equal "Subject Not Found", subjects_json.first["subject_code"]
    assert_response :success
  end

  test "should destroy event and not destroy associated sheets" do
    login(@project_editor)
    @subject_event = subject_events(:one)
    assert_difference("SubjectEvent.count", -1) do
      assert_difference("Sheet.current.count", 0) do
        delete destroy_event_project_subject_url(
          @project,
          @subject,
          event_id: @subject_event.event.id,
          subject_event_id: @subject_event.id,
          event_date: @subject_event.event_date_to_param
        )
      end
    end
    assert_redirected_to [@project, @subject]
  end

  test "should get events as project editor" do
    login(@project_editor)
    get events_project_subject_url(@project, @subject)
    assert_response :success
  end

  test "should get events as project viewer" do
    login(users(:associated))
    get events_project_subject_url(@project, @subject)
    assert_response :success
  end

  test "should get sheets as project editor" do
    login(@project_editor)
    get sheets_project_subject_url(@project, @subject)
    assert_response :success
  end

  test "should get sheets as project viewer" do
    login(users(:associated))
    get sheets_project_subject_url(@project, @subject)
    assert_response :success
  end

  test "should get timeline as project editor" do
    login(@project_editor)
    get timeline_project_subject_url(@project, @subject)
    assert_response :success
  end

  test "should get timeline as project viewer" do
    login(users(:associated))
    get timeline_project_subject_url(@project, @subject)
    assert_response :success
  end

  test "should get comments as project editor" do
    login(@project_editor)
    get comments_project_subject_url(@project, @subject)
    assert_response :success
  end

  test "should get comments as project viewer" do
    login(users(:associated))
    get comments_project_subject_url(@project, @subject)
    assert_response :success
  end

  test "should get files as project editor" do
    login(@project_editor)
    get files_project_subject_url(@project, @subject)
    assert_response :success
  end

  test "should get files as project viewer" do
    login(users(:associated))
    get files_project_subject_url(@project, @subject)
    assert_response :success
  end

  test "should get adverse events as project editor" do
    login(@project_editor)
    get adverse_events_project_subject_url(@project, @subject)
    assert_response :success
  end

  test "should get adverse events as project viewer" do
    login(users(:associated))
    get adverse_events_project_subject_url(@project, @subject)
    assert_response :success
  end

  test "should show designs available to a subject for a specific event" do
    login(@project_editor)
    get choose_date_project_subject_url(@project, @subject, event_id: "event-one")
    assert_response :success
  end

  test "should not show designs available to a subject for a non-existent event" do
    login(@project_editor)
    get choose_date_project_subject_url(@project, @subject, event_id: "event-does-not-exist")
    assert_redirected_to [@project, @subject]
  end

  test "should launch subject event for subject" do
    login(@project_editor)
    post launch_subject_event_project_subject_url(@project, @subject), params: {
      event_id: events(:one).id,
      subject_event: { event_date: "02/14/2015" }
    }
    assert_equal Date.parse("2015-02-14"), assigns(:subject_event).event_date
    assert_redirected_to event_project_subject_url(
      assigns(:project),
      assigns(:subject),
      event_id: assigns(:event),
      subject_event_id: assigns(:subject_event),
      event_date: assigns(:subject_event).event_date_to_param
    )
  end

  test "should not launch subject event for subject with invalid event" do
    login(@project_editor)
    post launch_subject_event_project_subject_url(@project, @subject), params: {
      event_id: -1,
      subject_event: { event_date: "02/14/2015" }
    }
    assert_redirected_to [@project, @subject]
  end

  test "should not launch subject event for subject with invalid date" do
    login(@project_editor)
    post launch_subject_event_project_subject_url(@project, @subject), params: {
      event_id: events(:one).id,
      subject_event: { event_date: "02/30/2015" }
    }
    assert_template "choose_date"
    assert_response :success
  end

  test "should get subject event for subject" do
    login(@project_editor)
    get event_project_subject_url(
      @project,
      @subject,
      event_id: events(:one).id,
      subject_event_id: subject_events(:one).id,
      event_date: subject_events(:one).event_date_to_param
    )
    assert_response :success
  end

  test "should get edit subject event for subject" do
    login(@project_editor)
    get edit_event_project_subject_url(
      @project,
      @subject,
      event_id: events(:one).id,
      subject_event_id: subject_events(:one).id,
      event_date: subject_events(:one).event_date_to_param
    )
    assert_response :success
  end

  test "should update subject event for subject" do
    login(@project_editor)
    post update_event_project_subject_url(
      @project,
      @subject,
      event_id: events(:one).id,
      subject_event_id: subject_events(:one).id
    ), params: {
      subject_event: { event_date: "12/4/2015" }
    }
    assert_equal Date.parse("2015-12-04"), assigns(:subject_event).event_date
    assert_redirected_to event_project_subject_url(
      assigns(:project),
      assigns(:subject),
      event_id: assigns(:event),
      subject_event_id: assigns(:subject_event),
      event_date: assigns(:subject_event).event_date_to_param
    )
  end

  test "should not update subject event for subject with invalid date" do
    login(@project_editor)
    post update_event_project_subject_url(
      @project,
      @subject,
      event_id: events(:one).id,
      subject_event_id: subject_events(:one).id
    ), params: {
      subject_event: { event_date: "12/0/2015" }
    }
    assert_template "edit_event"
    assert_response :success
  end

  test "should get choose site for new subject as project editor" do
    login(@project_editor)
    get choose_site_project_subjects_url(@project), params: { subject_code: "CodeNew" }
    assert_response :success
  end

  test "should redirect to subject when choosing site for existing subject as project editor" do
    login(@project_editor)
    get choose_site_project_subjects_url(@project), params: { subject_code: "Code01" }
    assert_redirected_to [assigns(:project), assigns(:subject)]
  end

  test "should redirect to subject when choosing site for existing subject as project viewer" do
    login(users(:associated))
    get choose_site_project_subjects_url(@project), params: { subject_code: "Code01" }
    assert_redirected_to [assigns(:project), assigns(:subject)]
  end

  test "should redirect to project when choosing site for non-existent subject as project viewer" do
    login(users(:associated))
    get choose_site_project_subjects_url(@project), params: { subject_code: "CodeNew" }
    assert_redirected_to assigns(:project)
  end

  test "should get index" do
    login(@project_editor)
    get project_subjects_url(@project)
    assert_response :success
  end

  test "should get index for randomized subjects" do
    login(@project_editor)
    get project_subjects_url(@project), params: { search: "is:randomized" }
    assert_response :success
  end

  test "should get index for unrandomized subjects" do
    login(@project_editor)
    get project_subjects_url(@project), params: { search: "not:randomized" }
    assert_response :success
  end

  test "should get index for subjects with open adverse events" do
    login(@project_editor)
    get project_subjects_url(@project), params: { search: "adverse-events:open" }
    assert_response :success
  end

  test "should get index for subjects with closed adverse events" do
    login(@project_editor)
    get project_subjects_url(@project), params: { search: "adverse-events:closed" }
    assert_response :success
  end

  test "should get index for subjects with adverse events" do
    login(@project_editor)
    get project_subjects_url(@project), params: { search: "has:adverse-events" }
    assert_response :success
  end

  test "should get index for subjects with no adverse events" do
    login(@project_editor)
    get project_subjects_url(@project), params: { search: "no:adverse-events" }
    assert_response :success
  end

  test "should get index for subjects with comments" do
    login(@project_editor)
    get project_subjects_url(@project), params: { search: "has:comments" }
    assert_response :success
  end

  test "should get index for subjects with no comments" do
    login(@project_editor)
    get project_subjects_url(@project), params: { search: "no:comments" }
    assert_response :success
  end

  test "should get index for subjects with files" do
    login(@project_editor)
    get project_subjects_url(@project), params: { search: "has:files" }
    assert_response :success
  end

  test "should get index for subjects with no files" do
    login(@project_editor)
    get project_subjects_url(@project), params: { search: "no:files" }
    assert_response :success
  end

  test "should get index for subjects missing designs" do
    login(@project_editor)
    get project_subjects_url(@project), params: { search: "designs:missing" }
    assert_response :success
  end

  test "should get index for subjects missing events" do
    login(@project_editor)
    get project_subjects_url(@project), params: { search: "events:missing" }
    assert_response :success
  end

  test "should get index for subjects with designs" do
    login(@project_editor)
    get project_subjects_url(@project), params: { search: "designs:design-one" }
    assert_response :success
  end

  test "should get index for subjects with events" do
    login(@project_editor)
    get project_subjects_url(@project), params: { search: "events:event-one" }
    assert_response :success
  end

  test "should get index for subjects without designs" do
    login(@project_editor)
    get project_subjects_url(@project), params: { search: "designs:!design-one" }
    assert_response :success
  end

  test "should get index for subjects without events" do
    login(@project_editor)
    get project_subjects_url(@project), params: { search: "events:!event-one" }
    assert_response :success
  end

  test "should get index for subjects with invalid key" do
    login(@project_editor)
    get project_subjects_url(@project), params: { search: "nokey:something" }
    assert_response :success
  end

  test "should get index with event" do
    login(@project_editor)
    get project_subjects_url(@project), params: {
      search: "events:#{events(:one).to_param}"
    }
    assert_response :success
  end

  test "should get index without event" do
    login(@project_editor)
    get project_subjects_url(@project), params: {
      search: "events:!#{events(:one).to_param}"
    }
    assert_response :success
  end

  test "should get index with event with entered design" do
    login(@project_editor)
    get project_subjects_url(@project), params: {
      search: "#{events(:one).to_param}:#{designs(:one).to_param}"
    }
    assert_response :success
  end

  test "should get index with event with unentered design" do
    login(@project_editor)
    get project_subjects_url(@project), params: {
      search: "#{events(:one).to_param}:#{designs(:one).to_param}:unentered"
    }
    assert_response :success
  end

  test "should get index with event with missing design" do
    login(@project_editor)
    get project_subjects_url(@project), params: {
      search: "#{events(:one).to_param}:#{designs(:one).to_param}:missing"
    }
    assert_response :success
  end

  test "should not get index with invalid project" do
    login(@project_editor)
    get project_subjects_url(-1)
    assert_redirected_to root_url
  end

  test "should get new" do
    login(@project_editor)
    get new_project_subject_url(@project)
    assert_response :success
  end

  test "should not get new subject with invalid project" do
    login(@project_editor)
    get new_project_subject_url(-1)
    assert_redirected_to root_url
  end

  test "should create subject and strip whitespace" do
    login(@project_editor)
    assert_difference("Subject.count") do
      post project_subjects_url(@project), params: {
        subject: { subject_code: " Code04 " },
        site_id: @subject.site_id
      }
    end
    assert_equal "Code04", assigns(:subject).subject_code
    assert_redirected_to project_subject_url(assigns(:subject).project, assigns(:subject))
  end

  test "should create subject with valid subject code" do
    login(@project_editor)
    assert_difference("Subject.count") do
      post project_subjects_url(@project), params: {
        subject: { subject_code: "S100" },
        site_id: sites(:site_with_subject_regex).id
      }
    end
    assert_redirected_to project_subject_url(assigns(:subject).project, assigns(:subject))
  end

  test "should not create subject with invalid subject code format" do
    login(@project_editor)
    assert_difference("Subject.count", 0) do
      post project_subjects_url(@project), params: {
        subject: { subject_code: "S100a" },
        site_id: sites(:site_with_subject_regex).id
      }
    end
    assert_equal ["must be in the following format: S1[0-9][0-9]"], assigns(:subject).errors[:subject_code]
    assert_template "new"
    assert_response :success
  end

  test "should not create subject with blank subject code" do
    login(@project_editor)
    assert_difference("Subject.count", 0) do
      post project_subjects_url(@project), params: {
        subject: { subject_code: "" },
        site_id: @subject.site_id
      }
    end
    assert_equal ["can't be blank"], assigns(:subject).errors[:subject_code]
    assert_template "new"
    assert_response :success
  end

  test "should not create subject with a subject code that differs in case to an existing subject code" do
    login(@project_editor)
    assert_difference("Subject.count", 0) do
      post project_subjects_url(@project), params: {
        subject: { subject_code: "code01" },
        site_id: @subject.site_id
      }
    end
    assert_equal ["has already been taken"], assigns(:subject).errors[:subject_code]
    assert_template "new"
    assert_response :success
  end

  test "should not create subject for invalid project" do
    login(users(:regular))
    assert_difference("Subject.count", 0) do
      post project_subjects_url(projects(:four)), params: {
        subject: { subject_code: "Code04" },
        site_id: @subject.site_id
      }
    end
    assert_redirected_to root_url
  end

  test "should not create subject for site viewer" do
    login(users(:site_one_viewer))
    assert_difference("Subject.count", 0) do
      post project_subjects_url(@project), params: {
        subject: { subject_code: "Code04" },
        site_id: sites(:one).id
      }
    end
    assert_redirected_to root_url
  end

  test "should create subject for site editor" do
    login(users(:site_one_editor))
    assert_difference("Subject.count") do
      post project_subjects_url(@project), params: {
        subject: { subject_code: "Code04" },
        site_id: sites(:one).id
      }
    end
    assert_redirected_to project_subject_url(assigns(:subject).project, assigns(:subject))
  end

  test "should not create subject for site editor for another site" do
    login(users(:site_one_editor))
    assert_difference("Subject.count", 0) do
      post project_subjects_url(@project), params: {
        subject: { subject_code: "Code04" },
        site_id: sites(:two).id
      }
    end
    assert_equal ["can't be blank"], assigns(:subject).errors[:site_id]
    assert_template "new"
    assert_response :success
  end

  test "should show subject" do
    login(@project_editor)
    get project_subject_url(@project, @subject)
    assert_response :success
  end

  test "should show subject to site user" do
    login(users(:site_one_viewer))
    get project_subject_url(@project, @subject)
    assert_response :success
  end

  test "should not show invalid subject" do
    login(@project_editor)
    get project_subject_url(@project, -1)
    assert_redirected_to project_subjects_url(@project)
  end

  test "should not show subject with invalid project" do
    login(@project_editor)
    get project_subject_url(-1, @subject)
    assert_redirected_to root_url
  end

  test "should not show subject on different site to site user" do
    login(users(:site_one_viewer))
    get project_subject_url(@project, subjects(:three))
    assert_redirected_to project_subjects_url(@project)
  end

  test "should get edit" do
    login(@project_editor)
    get edit_project_subject_url(@project, @subject)
    assert_response :success
  end

  test "should get edit for site editor" do
    login(users(:site_one_editor))
    get edit_project_subject_url(@project, @subject)
    assert_response :success
  end

  test "should not get edit for site editor for another site" do
    login(users(:site_one_editor))
    get edit_project_subject_url(@project, subjects(:three))
    assert_redirected_to project_subjects_url(@project)
  end

  test "should not get edit for site viewer" do
    login(users(:site_one_viewer))
    get edit_project_subject_url(@project, @subject)
    assert_redirected_to root_url
  end

  test "should not get edit for invalid subject" do
    login(@project_editor)
    get edit_project_subject_url(@project, -1)
    assert_redirected_to project_subjects_url(@project)
  end

  test "should not get edit with invalid project" do
    login(@project_editor)
    get edit_project_subject_url(-1, @subject)
    assert_redirected_to root_url
  end

  test "should update subject" do
    login(@project_editor)
    patch project_subject_url(@project, @subject), params: {
      subject: { subject_code: @subject.subject_code },
      site_id: @subject.site_id
    }
    assert_redirected_to project_subject_url(@project, @subject)
  end

  test "should not update subject with blank subject code" do
    login(@project_editor)
    patch project_subject_url(@project, @subject), params: {
      subject: { subject_code: "" },
      site_id: @subject.site_id
    }
    assert_equal ["can't be blank"], assigns(:subject).errors[:subject_code]
    assert_template "edit"
    assert_response :success
  end

  test "should not update invalid subject" do
    login(@project_editor)
    patch project_subject_url(@project, -1), params: {
      subject: { subject_code: @subject.subject_code },
      site_id: @subject.site_id
    }
    assert_redirected_to project_subjects_url(@project)
  end

  test "should not update subject with invalid project" do
    login(@project_editor)
    patch project_subject_url(-1, @subject), params: {
      subject: { subject_code: @subject.subject_code },
      site_id: @subject.site_id
    }
    assert_redirected_to root_url
  end

  test "should not update subject for site editor for another site" do
    login(users(:site_one_editor))
    patch project_subject_url(@project, subjects(:three)), params: {
      subject: { subject_code: "New Subject Code" },
      site_id: sites(:one).id
    }
    assert_redirected_to project_subjects_url(@project)
  end

  test "should destroy unrandomized subject" do
    login(users(:regular))
    assert_difference("Subject.current.count", -1) do
      delete project_subject_url(@project, subjects(:unrandomized))
    end
    assert_redirected_to project_subjects_url(@project)
  end

  test "should not destroy subject with invalid project" do
    login(@project_editor)
    assert_difference("Subject.current.count", 0) do
      delete project_subject_url(-1, @subject)
    end
    assert_redirected_to root_url
  end

  test "should not destroy randomized subject" do
    login(users(:regular))
    assert_difference("Subject.current.count", 0) do
      delete project_subject_url(projects(:two), subjects(:randomized))
    end
    assert_redirected_to [projects(:two), subjects(:randomized)]
  end
end
