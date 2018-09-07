# frozen_string_literal: true

require "test_helper"

# Set up ApplicationSystemTestCase system tests.
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

  setup do
    @screenshots_enabled = true
    @counter = 0
  end

  def screenshot(file_name)
    return unless @screenshots_enabled
    @counter += 1
    relative_location = File.join(
      "docs",
      Slice::VERSION::STRING,
      "screenshots",
      "#{file_name}-#{format("%02d", @counter)}.png"
    )
    page.save_screenshot(Rails.root.join(relative_location))
    # puts "[Screenshot]: #{relative_location}"
  end

  def click_form_submit
    find("input[type=submit]").click
  end

  def click_element(selector)
    page.execute_script("$(\"#{selector}\").click();")
  end
end
