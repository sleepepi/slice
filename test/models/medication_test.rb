require "test_helper"

class MedicationTest < ActiveSupport::TestCase
  test "should parse full date" do
    medication = Medication.create(
      project: projects(:medications),
      subject: subjects(:meds_01),
      name: "Medication",
      start_date_fuzzy_edit: "1",
      start_date_fuzzy_mo_1: "0",
      start_date_fuzzy_mo_2: "1",
      start_date_fuzzy_dy_1: "0",
      start_date_fuzzy_dy_2: "1",
      start_date_fuzzy_yr_1: "1",
      start_date_fuzzy_yr_2: "9",
      start_date_fuzzy_yr_3: "9",
      start_date_fuzzy_yr_4: "0",
    )
    assert medication.valid?
    assert_equal "Jan 1, 1990", medication.fuzzy_pretty(:start_date_fuzzy)
  end

  test "should parse fuzzy year, month, and day" do
    medication = Medication.create(
      project: projects(:medications),
      subject: subjects(:meds_01),
      name: "Medication",
      start_date_fuzzy_edit: "1",
      start_date_fuzzy_mo_1: "9",
      start_date_fuzzy_mo_2: "9",
      start_date_fuzzy_dy_1: "9",
      start_date_fuzzy_dy_2: "9",
      start_date_fuzzy_yr_1: "9",
      start_date_fuzzy_yr_2: "9",
      start_date_fuzzy_yr_3: "9",
      start_date_fuzzy_yr_4: "9",
    )
    assert medication.valid?
    assert_equal "Unknown", medication.fuzzy_pretty(:start_date_fuzzy)
  end

  test "should parse fuzzy month and day" do
    medication = Medication.create(
      project: projects(:medications),
      subject: subjects(:meds_01),
      name: "Medication",
      start_date_fuzzy_edit: "1",
      start_date_fuzzy_mo_1: "9",
      start_date_fuzzy_mo_2: "9",
      start_date_fuzzy_dy_1: "9",
      start_date_fuzzy_dy_2: "9",
      start_date_fuzzy_yr_1: "1",
      start_date_fuzzy_yr_2: "9",
      start_date_fuzzy_yr_3: "9",
      start_date_fuzzy_yr_4: "0",
    )
    assert medication.valid?
    assert_equal "1990", medication.fuzzy_pretty(:start_date_fuzzy)
  end

  test "should parse fuzzy day" do
    medication = Medication.create(
      project: projects(:medications),
      subject: subjects(:meds_01),
      name: "Medication",
      start_date_fuzzy_edit: "1",
      start_date_fuzzy_mo_1: "0",
      start_date_fuzzy_mo_2: "1",
      start_date_fuzzy_dy_1: "9",
      start_date_fuzzy_dy_2: "9",
      start_date_fuzzy_yr_1: "1",
      start_date_fuzzy_yr_2: "9",
      start_date_fuzzy_yr_3: "9",
      start_date_fuzzy_yr_4: "0",
    )
    assert medication.valid?
    assert_equal "Jan 1990", medication.fuzzy_pretty(:start_date_fuzzy)
  end

  test "should not parse invalid date" do
    medication = Medication.create(
      project: projects(:medications),
      subject: subjects(:meds_01),
      name: "Medication",
      start_date_fuzzy_edit: "1",
      start_date_fuzzy_mo_1: "0",
      start_date_fuzzy_mo_2: "2",
      start_date_fuzzy_dy_1: "3",
      start_date_fuzzy_dy_2: "1",
      start_date_fuzzy_yr_1: "1",
      start_date_fuzzy_yr_2: "9",
      start_date_fuzzy_yr_3: "9",
      start_date_fuzzy_yr_4: "0",
    )
    assert !medication.valid?
    assert_equal ["is invalid"], medication.errors[:start_date_fuzzy_yr]
    assert_equal ["is invalid"], medication.errors[:start_date_fuzzy_mo]
    assert_equal ["is invalid"], medication.errors[:start_date_fuzzy_dy]
    assert_equal ["is invalid"], medication.errors[:start_date_fuzzy]
    assert_nil medication.fuzzy_pretty(:start_date_fuzzy)
  end

  test "should not parse fuzzy year with a month and day present" do
    medication = Medication.create(
      project: projects(:medications),
      subject: subjects(:meds_01),
      name: "Medication",
      start_date_fuzzy_edit: "1",
      start_date_fuzzy_mo_1: "0",
      start_date_fuzzy_mo_2: "1",
      start_date_fuzzy_dy_1: "0",
      start_date_fuzzy_dy_2: "1",
      start_date_fuzzy_yr_1: "9",
      start_date_fuzzy_yr_2: "9",
      start_date_fuzzy_yr_3: "9",
      start_date_fuzzy_yr_4: "9",
    )
    assert !medication.valid?
    assert_equal ["should be 99"], medication.errors[:start_date_fuzzy_mo]
    assert_equal ["should be 99"], medication.errors[:start_date_fuzzy_dy]
    assert_equal ["month and day should be 99 if year is unknown"], medication.errors[:start_date_fuzzy]
    assert_nil medication.fuzzy_pretty(:start_date_fuzzy)
  end

  test "should not parse fuzzy year and month with a day present" do
    medication = Medication.create(
      project: projects(:medications),
      subject: subjects(:meds_01),
      name: "Medication",
      start_date_fuzzy_edit: "1",
      start_date_fuzzy_mo_1: "9",
      start_date_fuzzy_mo_2: "9",
      start_date_fuzzy_dy_1: "0",
      start_date_fuzzy_dy_2: "1",
      start_date_fuzzy_yr_1: "9",
      start_date_fuzzy_yr_2: "9",
      start_date_fuzzy_yr_3: "9",
      start_date_fuzzy_yr_4: "9",
    )
    assert !medication.valid?
    assert_equal ["should be 99"], medication.errors[:start_date_fuzzy_dy]
    assert_equal ["day should be 99 if month and year are unknown"], medication.errors[:start_date_fuzzy]
    assert_nil medication.fuzzy_pretty(:start_date_fuzzy)
  end

  test "should not parse fuzzy year with a month present" do
    medication = Medication.create(
      project: projects(:medications),
      subject: subjects(:meds_01),
      name: "Medication",
      start_date_fuzzy_edit: "1",
      start_date_fuzzy_mo_1: "0",
      start_date_fuzzy_mo_2: "1",
      start_date_fuzzy_dy_1: "9",
      start_date_fuzzy_dy_2: "9",
      start_date_fuzzy_yr_1: "9",
      start_date_fuzzy_yr_2: "9",
      start_date_fuzzy_yr_3: "9",
      start_date_fuzzy_yr_4: "9",
    )
    assert !medication.valid?
    assert_equal ["should be 99"], medication.errors[:start_date_fuzzy_mo]
    assert_equal ["month should be 99 if year is unknown"], medication.errors[:start_date_fuzzy]
    assert_nil medication.fuzzy_pretty(:start_date_fuzzy)
  end

  test "should not parse fuzzy month with a day present" do
    medication = Medication.create(
      project: projects(:medications),
      subject: subjects(:meds_01),
      name: "Medication",
      start_date_fuzzy_edit: "1",
      start_date_fuzzy_mo_1: "9",
      start_date_fuzzy_mo_2: "9",
      start_date_fuzzy_dy_1: "0",
      start_date_fuzzy_dy_2: "1",
      start_date_fuzzy_yr_1: "1",
      start_date_fuzzy_yr_2: "9",
      start_date_fuzzy_yr_3: "9",
      start_date_fuzzy_yr_4: "0",
    )
    assert !medication.valid?
    assert_equal ["should be 99"], medication.errors[:start_date_fuzzy_dy]
    assert_equal ["day should be 99 if month is unknown"], medication.errors[:start_date_fuzzy]
    assert_nil medication.fuzzy_pretty(:start_date_fuzzy)
  end

  test "should not parse fuzzy year in the future" do
    medication = Medication.create(
      project: projects(:medications),
      subject: subjects(:meds_01),
      name: "Medication",
      start_date_fuzzy_edit: "1",
      start_date_fuzzy_mo_1: "9",
      start_date_fuzzy_mo_2: "9",
      start_date_fuzzy_dy_1: "9",
      start_date_fuzzy_dy_2: "9",
      start_date_fuzzy_yr_1: "8",
      start_date_fuzzy_yr_2: "9",
      start_date_fuzzy_yr_3: "9",
      start_date_fuzzy_yr_4: "9",
    )
    assert !medication.valid?
    assert_equal ["can't be in future"], medication.errors[:start_date_fuzzy_yr]
    assert_equal ["can't be in future"], medication.errors[:start_date_fuzzy]
    assert_nil medication.fuzzy_pretty(:start_date_fuzzy)
  end

  test "should not parse fuzzy year and month in the future" do
    medication = Medication.create(
      project: projects(:medications),
      subject: subjects(:meds_01),
      name: "Medication",
      start_date_fuzzy_edit: "1",
      start_date_fuzzy_mo_1: "1",
      start_date_fuzzy_mo_2: "2",
      start_date_fuzzy_dy_1: "9",
      start_date_fuzzy_dy_2: "9",
      start_date_fuzzy_yr_1: "8",
      start_date_fuzzy_yr_2: "9",
      start_date_fuzzy_yr_3: "9",
      start_date_fuzzy_yr_4: "9",
    )
    assert !medication.valid?
    assert_equal ["can't be in future"], medication.errors[:start_date_fuzzy_yr]
    assert_equal ["can't be in future"], medication.errors[:start_date_fuzzy_mo]
    assert_equal ["can't be in future"], medication.errors[:start_date_fuzzy]
    assert_nil medication.fuzzy_pretty(:start_date_fuzzy)
  end

  test "should not parse fuzzy year, month, and day in the future" do
    medication = Medication.create(
      project: projects(:medications),
      subject: subjects(:meds_01),
      name: "Medication",
      start_date_fuzzy_edit: "1",
      start_date_fuzzy_mo_1: "1",
      start_date_fuzzy_mo_2: "2",
      start_date_fuzzy_dy_1: "3",
      start_date_fuzzy_dy_2: "1",
      start_date_fuzzy_yr_1: "8",
      start_date_fuzzy_yr_2: "9",
      start_date_fuzzy_yr_3: "9",
      start_date_fuzzy_yr_4: "9",
    )
    assert !medication.valid?
    assert_equal ["can't be in future"], medication.errors[:start_date_fuzzy_yr]
    assert_equal ["can't be in future"], medication.errors[:start_date_fuzzy_mo]
    assert_equal ["can't be in future"], medication.errors[:start_date_fuzzy_dy]
    assert_equal ["can't be in future"], medication.errors[:start_date_fuzzy]
    assert_nil medication.fuzzy_pretty(:start_date_fuzzy)
  end

  test "should not parse blank year fields" do
    medication = Medication.create(
      project: projects(:medications),
      subject: subjects(:meds_01),
      name: "Medication",
      start_date_fuzzy_edit: "1",
      start_date_fuzzy_mo_1: "0",
      start_date_fuzzy_mo_2: "1",
      start_date_fuzzy_dy_1: "0",
      start_date_fuzzy_dy_2: "1",
      start_date_fuzzy_yr_1: "",
      start_date_fuzzy_yr_2: "",
      start_date_fuzzy_yr_3: "9",
      start_date_fuzzy_yr_4: "0",
    )
    assert !medication.valid?
    assert_equal ["can't be blank"], medication.errors[:start_date_fuzzy_yr]
    assert_equal ["can't have blank fields"], medication.errors[:start_date_fuzzy]
    assert_nil medication.fuzzy_pretty(:start_date_fuzzy)
  end

  test "should not parse blank month fields" do
    medication = Medication.create(
      project: projects(:medications),
      subject: subjects(:meds_01),
      name: "Medication",
      start_date_fuzzy_edit: "1",
      start_date_fuzzy_mo_1: "",
      start_date_fuzzy_mo_2: "1",
      start_date_fuzzy_dy_1: "0",
      start_date_fuzzy_dy_2: "1",
      start_date_fuzzy_yr_1: "1",
      start_date_fuzzy_yr_2: "9",
      start_date_fuzzy_yr_3: "9",
      start_date_fuzzy_yr_4: "0",
    )
    assert !medication.valid?
    assert_equal ["can't be blank"], medication.errors[:start_date_fuzzy_mo]
    assert_equal ["can't have blank fields"], medication.errors[:start_date_fuzzy]
    assert_nil medication.fuzzy_pretty(:start_date_fuzzy)
  end

  test "should not parse blank day fields" do
    medication = Medication.create(
      project: projects(:medications),
      subject: subjects(:meds_01),
      name: "Medication",
      start_date_fuzzy_edit: "1",
      start_date_fuzzy_mo_1: "0",
      start_date_fuzzy_mo_2: "1",
      start_date_fuzzy_dy_1: "",
      start_date_fuzzy_dy_2: "1",
      start_date_fuzzy_yr_1: "1",
      start_date_fuzzy_yr_2: "9",
      start_date_fuzzy_yr_3: "9",
      start_date_fuzzy_yr_4: "0",
    )
    assert !medication.valid?
    assert_equal ["can't be blank"], medication.errors[:start_date_fuzzy_dy]
    assert_equal ["can't have blank fields"], medication.errors[:start_date_fuzzy]
    assert_nil medication.fuzzy_pretty(:start_date_fuzzy)
  end

  test "should parse blank date" do
    medication = Medication.create(
      project: projects(:medications),
      subject: subjects(:meds_01),
      name: "Medication",
      start_date_fuzzy_edit: "1",
      start_date_fuzzy_mo_1: "",
      start_date_fuzzy_mo_2: "",
      start_date_fuzzy_dy_1: "",
      start_date_fuzzy_dy_2: "",
      start_date_fuzzy_yr_1: "",
      start_date_fuzzy_yr_2: "",
      start_date_fuzzy_yr_3: "",
      start_date_fuzzy_yr_4: "",
    )
    assert medication.valid?
    assert_nil medication.fuzzy_pretty(:start_date_fuzzy)
  end
end
