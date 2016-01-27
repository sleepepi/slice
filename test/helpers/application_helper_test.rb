# frozen_string_literal: true

require 'test_helper'

SimpleCov.command_name "test:helpers"

class ApplicationHelperTest < ActionView::TestCase
  test "should show date" do
    date = Date.today + 5.days
    date = date.change(year: Date.today.year)
    assert_equal date.strftime("%b %d"), simple_date(date)
  end

  test "should show date today" do
    date = Date.today
    assert_equal 'Today', simple_date(date)
  end

  test "should show date yesterday" do
    date = Date.today - 1.day
    assert_equal 'Yesterday', simple_date(date)
  end

  test "should show date tomorrow" do
    date = Date.today + 1.day
    assert_equal 'Tomorrow', simple_date(date)
  end

  test "should show full date from last year" do
    date = Date.today - 1.year
    assert_equal date.strftime("%b %d, %Y"), simple_date(date)
  end

  test "should show time" do
    time = Time.zone.now
    assert_equal time.strftime("<b>Today</b> at %I:%M %p"), simple_time(time)
  end

  test "should show full time from yesterday" do
    time = Time.zone.now - 1.day
    time += 2.days if time.year != Time.zone.now.year # Test would fail if run on Jan 1st otherwise
    assert_equal time.strftime("on %b %d at %I:%M %p"), simple_time(time)
  end

  test "should show full time from last year" do
    time = Time.zone.now - 1.year
    assert_equal time.strftime("on %b %d, %Y at %I:%M %p"), simple_time(time)
  end

  test "should show recent activity" do
    assert recent_activity(nil).is_a?(String)
    assert recent_activity('').is_a?(String)
    assert recent_activity(Time.zone.now).is_a?(String)
    assert recent_activity(Time.zone.now - 12.hours).is_a?(String)
    assert recent_activity(Time.zone.now - 1.day).is_a?(String)
    assert recent_activity(Time.zone.now - 2.days).is_a?(String)
    assert recent_activity(Time.zone.now - 1.week).is_a?(String)
    assert recent_activity(Time.zone.now - 1.month).is_a?(String)
    assert recent_activity(Time.zone.now - 6.month).is_a?(String)
    assert recent_activity(Time.zone.now - 1.year).is_a?(String)
    assert recent_activity(Time.zone.now - 2.year).is_a?(String)
  end

  test "should mark javascript url as unsafe" do
    assert_equal false, safe_url?("javascript:;")
  end

  test "should mark blank url as unsafe" do
    assert_equal false, safe_url?("")
    assert_equal false, safe_url?(nil)
  end

  test "should mark known schemes for urls as safe" do
    assert_equal true, safe_url?("http://www.example.com")
    assert_equal true, safe_url?("https://www.example.com")
    assert_equal true, safe_url?("ftp://ftp.example.com")
    assert_equal true, safe_url?("mailto:valid@example.com")
  end

end
