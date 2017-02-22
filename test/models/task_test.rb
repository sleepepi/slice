# frozen_string_literal: true

require 'test_helper'

# Assure certain task methods work as expected.
class TaskTest < ActiveSupport::TestCase
  test 'task is a phonecall' do
    assert_equal true, Task.new(description: 'Five-Month Phonecall').phonecall?
  end

  test 'task is a visit' do
    assert_equal true, Task.new(description: '6 Month Visit').visit?
  end

  test 'task calendar description' do
    assert_equal 'Code01 Phonecall', tasks(:one).calendar_description
    assert_equal 'Visit', Task.new(description: 'Visit').calendar_description
  end

  test 'moving task also moves windows' do
    new_date = Date.parse('2016-02-20')
    tasks(:one).move_to_date(new_date)
    assert_equal new_date, tasks(:one).due_date
    assert_equal Date.parse('2016-02-17'), tasks(:one).window_start_date
    assert_equal Date.parse('2016-02-23'), tasks(:one).window_end_date
  end
end
