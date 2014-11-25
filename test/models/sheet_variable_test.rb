require 'test_helper'

class SheetVariableTest < ActiveSupport::TestCase

  test "get max grids position" do
    assert_equal 1, sheet_variables(:has_grid).max_grids_position
  end

  # test "the truth" do
  #   assert true
  # end

  test "get dropdown valuable class" do
    assert_equal Valuables::SingleResponse, Valuables.for(sheet_variables(:gender_subject_two)).class
  end

  test "get dropdown name value" do
    assert_equal "m: Male", sheet_variables(:gender_male).get_response(:name)
  end

  test "get dropdown raw value" do
    assert_equal "m", sheet_variables(:gender_male).get_response(:raw)
  end

  test "get radio valuable class" do
    assert_equal Valuables::SingleResponse, Valuables.for(sheet_variables(:gender_subject_two)).class
  end

  test "get radio name value" do
    assert_equal "f: Female", sheet_variables(:gender_subject_two).get_response(:name)
  end

  test "get radio raw value" do
    assert_equal "f", sheet_variables(:gender_subject_two).get_response(:raw)
  end

  test "get checkbox valuable class" do
    assert_equal Valuables::MultipleResponse, Valuables.for(sheet_variables(:course_work)).class
  end

  test "get checkbox name value" do
    assert_equal ['acct101: ACCT 101','econ101: ECON 101'], sheet_variables(:course_work).get_response(:name)
  end

  test "get checkbox raw value" do
    assert_equal ['acct101','econ101'], sheet_variables(:course_work).get_response(:raw)
  end

  test "get numeric valuable class" do
    assert_equal Valuables::NumericResponse, Valuables.for(sheet_variables(:weight_subject_one)).class
  end

  test "get numeric name value" do
    assert_equal "70.0 kg", sheet_variables(:weight_subject_one).get_response(:name)
  end

  test "get numeric raw value" do
    assert_equal 70.0, sheet_variables(:weight_subject_one).get_response(:raw)
  end

  test "get calculated valuable class" do
    assert_equal Valuables::NumericResponse, Valuables.for(sheet_variables(:calculated)).class
  end

  test "get calculated name value" do
    assert_equal "24.36 kg / (m * m)", sheet_variables(:calculated).get_response(:name)
  end

  test "get calculated raw value" do
    assert_equal 24.36, sheet_variables(:calculated).get_response(:raw)
  end

  test "get file valuable class" do
    assert_equal Valuables::FileAttachment, Valuables.for(sheet_variables(:file_attachment)).class
  end

  test "get file name value" do
    assert_equal "rails.png", sheet_variables(:file_attachment).get_response(:name)
  end

  test "get file raw value" do
    assert_equal GenericUploader, sheet_variables(:file_attachment).get_response(:raw).class
    assert_equal File.size('test/support/sheet_variables/11993616/response_file/rails.png'), sheet_variables(:file_attachment).get_response(:raw).size
  end

  test "get integer valuable class" do
    assert_equal Valuables::IntegerResponse, Valuables.for(sheet_variables(:integer)).class
  end

  test "get integer name value" do
    assert_equal "-9: Unknown", sheet_variables(:integer).get_response(:name)
  end

  test "get integer raw value" do
    assert_equal -9, sheet_variables(:integer).get_response(:raw)
  end

  test "get string valuable class" do
    assert_equal Valuables::Default, Valuables.for(sheet_variables(:string)).class
  end

  test "get string name value" do
    assert_equal "Weight Lifting and Salsa", sheet_variables(:string).get_response(:name)
  end

  test "get string raw value" do
    assert_equal "Weight Lifting and Salsa", sheet_variables(:string).get_response(:raw)
  end

  test "get text valuable class" do
    assert_equal Valuables::Default, Valuables.for(sheet_variables(:text)).class
  end

  test "get text name value" do
    assert_equal "This Text is across \nMultiple Lines", sheet_variables(:text).get_response(:name)
  end

  test "get text raw value" do
    assert_equal "This Text is across \nMultiple Lines", sheet_variables(:text).get_response(:raw)
  end

  test "get grid valuable class" do
    assert_equal Valuables::GridResponse, Valuables.for(sheet_variables(:grid)).class
  end

  test "get grid name value" do
    assert_equal "[{\"change_options\":\"2: Option 1\"},{\"change_options\":\"3: Option 2\"},{\"change_options\":\"3: Option 2\"},{\"change_options\":\"1: Option 3\"},{\"change_options\":\"1: Option 3\"},{\"change_options\":\"1: Option 3\"}]", sheet_variables(:grid).get_response(:name)
  end

  test "get grid raw value" do
    assert_equal "[{\"change_options\":\"2\"},{\"change_options\":\"3\"},{\"change_options\":\"3\"},{\"change_options\":\"1\"},{\"change_options\":\"1\"},{\"change_options\":\"1\"}]", sheet_variables(:grid).get_response(:raw)
  end

  test "get date valuable class" do
    assert_equal Valuables::DateResponse, Valuables.for(sheet_variables(:date)).class
  end

  test "get date name value" do
    assert_equal "04/17/2013", sheet_variables(:date).get_response(:name)
  end

  test "get date raw value" do
    assert_equal "2013-04-17", sheet_variables(:date).get_response(:raw)
  end

  test "get time valuable class" do
    assert_equal Valuables::TimeResponse, Valuables.for(sheet_variables(:time)).class
  end

  test "get time name value" do
    assert_equal "22:30:00", sheet_variables(:time).get_response(:name)
  end

  test "get time raw value" do
    assert_equal "22:30:00", sheet_variables(:time).get_response(:raw)
  end


end
