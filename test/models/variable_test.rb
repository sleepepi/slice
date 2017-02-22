# frozen_string_literal: true

require 'test_helper'

# Tests to assure that certain variable methods work as expected.
class VariableTest < ActiveSupport::TestCase
  test 'should get variable tooltip' do
    assert_equal "[-100, 100] years", Variable.new(hard_minimum: -100, hard_maximum: 100, soft_minimum: 0, soft_maximum: 50, units: 'years').range_tooltip
    assert_equal ">= -100 years",     Variable.new(hard_minimum: -100, soft_minimum: 0, units: 'years').range_tooltip
    assert_equal "<= 100 years",      Variable.new(hard_maximum: 100, soft_maximum: 50, units: 'years').range_tooltip
    assert_equal "",                  Variable.new(units: 'years').range_tooltip
    assert_equal "[0, 50]",           Variable.new(soft_minimum: 0, soft_maximum: 50).range_tooltip
    assert_equal ">= 0",              Variable.new(soft_minimum: 0).range_tooltip
    assert_equal "<= 50",             Variable.new(soft_maximum: 50).range_tooltip
  end

  test 'should be first scale variable if scale variable exists by itself in a grid' do
    assert_equal true, variables(:scale_in_grid).first_scale_variable?(designs(:contains_single_scale_in_grid))
  end
end
