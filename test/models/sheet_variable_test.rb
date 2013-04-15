require 'test_helper'

class SheetVariableTest < ActiveSupport::TestCase

  test "get max grids position" do
    assert_equal 0, sheet_variables(:has_grid).max_grids_position
  end

  # test "the truth" do
  #   assert true
  # end
end
