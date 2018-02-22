# frozen_string_literal: true

require "test_helper"

# Assure that recent activity works as expected.
class TimeHelperTest < ActionView::TestCase
  test "should show recent activity" do
    assert recent_activity(nil).is_a?(String)
    assert recent_activity("").is_a?(String)
    assert recent_activity(Time.zone.now).is_a?(String)
    assert recent_activity(Time.zone.now - 12.hours).is_a?(String)
    assert recent_activity(Time.zone.now - 1.day).is_a?(String)
    assert recent_activity(Time.zone.now - 2.days).is_a?(String)
    assert recent_activity(Time.zone.now - 1.week).is_a?(String)
    assert recent_activity(Time.zone.now - 1.month).is_a?(String)
    assert recent_activity(Time.zone.now - 6.months).is_a?(String)
    assert recent_activity(Time.zone.now - 1.year).is_a?(String)
    assert recent_activity(Time.zone.now - 2.years).is_a?(String)
  end
end
