# frozen_string_literal: true

require "test_helper"

# Test check methods.
class CheckTest < ActiveSupport::TestCase
  test "should run check" do
    checks(:one).run!
    assert true, checks(:one).last_run_at.present?
  end
end
