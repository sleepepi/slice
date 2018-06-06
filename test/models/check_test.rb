# frozen_string_literal: true

require "test_helper"

# Test check methods.
class CheckTest < ActiveSupport::TestCase
  test "gets check sheets" do
    assert true, checks(:one).sheets.present?
  end

  test "gets check subjects" do
    assert true, checks(:one).subjects.present?
  end

  test "runs check" do
    checks(:one).run!
    assert true, checks(:one).last_run_at.present?
  end
end
