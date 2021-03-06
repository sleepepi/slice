# frozen_string_literal: true

require "test_helper"

# Tests to assure that adverse events can be shared with medical monitors.
class AdverseEventControllerTest < ActionDispatch::IntegrationTest
  setup do
    @shared = adverse_events(:shared)
  end

  test "should get show for shared adverse event" do
    get adverse_event_show_url(authentication_token: @shared.id_and_token)
    assert_response :success
  end

  test "should not get show for unshared adverse event" do
    get adverse_event_show_url(authentication_token: adverse_events(:one).id_and_token)
    assert_redirected_to about_path
  end

  test "should review shared adverse event" do
    assert_difference("AdverseEventReview.count") do
      post adverse_event_review_url(authentication_token: @shared.id_and_token), params: {
        adverse_event_review: { name: "Reviewer", comment: "I reviewed this." }
      }
    end
    assert_redirected_to about_path
  end

  test "should not submit review of shared adverse event with blank name or comment" do
    assert_difference("AdverseEventReview.count", 0) do
      post adverse_event_review_url(authentication_token: @shared.id_and_token), params: {
        adverse_event_review: { name: "", comment: "" }
      }
    end
    assert_template "show"
    assert_response :success
  end
end
