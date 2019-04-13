# frozen_string_literal: true

require 'test_helper'

# Tests to make sure data is stored and formatted correctly
class SheetVariableTest < ActiveSupport::TestCase
  test 'get dropdown' do
    assert_equal Formatters::DomainFormatter, Formatters.for(sheet_variables(:gender_subject_two).variable).class
    assert_equal 'm: Male', sheet_variables(:gender_male).get_response(:name)
    assert_equal 'm', sheet_variables(:gender_male).get_response(:raw)
  end

  test 'get radio' do
    assert_equal Formatters::DomainFormatter, Formatters.for(sheet_variables(:gender_subject_two).variable).class
    assert_equal 'f: Female', sheet_variables(:gender_subject_two).get_response(:name)
    assert_equal 'f', sheet_variables(:gender_subject_two).get_response(:raw)
  end

  test 'get checkbox' do
    assert_equal Formatters::DomainFormatter, Formatters.for(sheet_variables(:course_work).variable).class
    assert_equal ['acct101: ACCT 101', 'econ101: ECON 101'], sheet_variables(:course_work).get_response(:name)
    assert_equal %w(acct101 econ101), sheet_variables(:course_work).get_response(:raw)
  end

  test 'get numeric' do
    assert_equal Formatters::NumericFormatter, Formatters.for(sheet_variables(:weight_subject_one).variable).class
    assert_equal '70.0 kg', sheet_variables(:weight_subject_one).get_response(:name)
    assert_equal 70.0, sheet_variables(:weight_subject_one).get_response(:raw)
  end

  test "get calculated" do
    assert_equal Formatters::CalculatedFormatter, Formatters.for(sheet_variables(:calculated).variable).class
    assert_equal "24.36 kg / (m * m)", sheet_variables(:calculated).get_response(:name)
    assert_equal 24.36, sheet_variables(:calculated).get_response(:raw)
  end

  test 'get file' do
    file = sheet_variables(:file_attachment).get_response(:raw)
    assert_equal Formatters::FileFormatter, Formatters.for(sheet_variables(:file_attachment).variable).class
    assert_equal GenericUploader, file.class
    assert_equal 'rails.png', sheet_variables(:file_attachment).get_response(:name)
    assert_equal(
      File.size(File.join(CarrierWave::Uploader::Base.root, "sheet_variables", "11993616", "response_file", "rails.png")),
      file.size
    )
  end

  test 'get integer' do
    assert_equal Formatters::IntegerFormatter, Formatters.for(sheet_variables(:integer).variable).class
    assert_equal '-9: Unknown', sheet_variables(:integer).get_response(:name)
    assert_equal('-9', sheet_variables(:integer).get_response(:raw))
  end

  test 'get string' do
    assert_equal Formatters::DefaultFormatter, Formatters.for(sheet_variables(:string).variable).class
    assert_equal 'Weight Lifting and Salsa', sheet_variables(:string).get_response(:name)
    assert_equal 'Weight Lifting and Salsa', sheet_variables(:string).get_response(:raw)
  end

  test 'get text' do
    assert_equal Formatters::DefaultFormatter, Formatters.for(sheet_variables(:text).variable).class
    assert_equal "This Text is across \nMultiple Lines", sheet_variables(:text).get_response(:name)
    assert_equal "This Text is across \nMultiple Lines", sheet_variables(:text).get_response(:raw)
  end

  test 'get grid' do
    assert_equal Formatters::DefaultFormatter, Formatters.for(sheet_variables(:grid).variable).class
    assert_equal '[{"change_options":"2: Option 1"},{"change_options":"3: Option 2"},{"change_options":"3: Option 2"},{"change_options":"1: Option 3"},{"change_options":"1: Option 3"},{"change_options":"1: Option 3"}]', sheet_variables(:grid).get_response(:name)
    assert_equal '[{"change_options":"2"},{"change_options":"3"},{"change_options":"3"},{"change_options":"1"},{"change_options":"1"},{"change_options":"1"}]', sheet_variables(:grid).get_response(:raw)
  end

  test 'get date' do
    assert_equal Formatters::DateFormatter, Formatters.for(sheet_variables(:date).variable).class
    assert_equal '04/17/2013', sheet_variables(:date).get_response(:name)
    assert_equal '2013-04-17', sheet_variables(:date).get_response(:raw)
  end

  test 'get time of day' do
    assert_equal Formatters::TimeOfDayFormatter, Formatters.for(sheet_variables(:time_of_day).variable).class
    assert_equal '22:30:00', sheet_variables(:time_of_day).get_response(:name)
    assert_equal '81000', sheet_variables(:time_of_day).get_response(:raw)
  end

  test 'get time duration' do
    assert_equal Formatters::TimeDurationFormatter, Formatters.for(sheet_variables(:time_duration).variable).class
    assert_equal '57 hours 2 minutes 3 seconds', sheet_variables(:time_duration).get_response(:name)
    assert_equal '205323', sheet_variables(:time_duration).get_response(:raw)
  end
end
