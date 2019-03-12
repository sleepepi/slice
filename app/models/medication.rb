# frozen_string_literal: true

# Tracks a medication a subject is taking.
class Medication < ApplicationRecord
  # Concerns
  include Deletable

  # Callbacks
  before_validation :set_fuzzy_dates

  # Validations
  validates :name, presence: true

  # Relationships
  belongs_to :project
  belongs_to :subject
  belongs_to :parent_medication, class_name: "Medication", optional: true
  has_many :medication_values

  attr_writer :start_date_fuzzy_mo_1, :start_date_fuzzy_mo_2,
              :start_date_fuzzy_dy_1, :start_date_fuzzy_dy_2,
              :start_date_fuzzy_yr_1, :start_date_fuzzy_yr_2,
              :start_date_fuzzy_yr_3, :start_date_fuzzy_yr_4,
              :stop_date_fuzzy_mo_1, :stop_date_fuzzy_mo_2,
              :stop_date_fuzzy_dy_1, :stop_date_fuzzy_dy_2,
              :stop_date_fuzzy_yr_1, :stop_date_fuzzy_yr_2,
              :stop_date_fuzzy_yr_3, :stop_date_fuzzy_yr_4

  attr_accessor :start_date_fuzzy_edit, :stop_date_fuzzy_edit, :medication_variables

  # Methods

  def stopped?
    stop_date_fuzzy.present?
  end

  def fuzzy_pretty(key)
    return nil if self[key].blank?

    yr = self[key][0..3]
    mo = self[key][4..5]
    dy = self[key][6..7]

    if yr == "9999" && mo == "99" && dy == "99"
      "Unknown"
    elsif mo == "99" && dy == "99"
      yr
    elsif dy == "99"
      "#{Date::ABBR_MONTHNAMES[mo.to_i]} #{yr}"
    else
      "#{Date::ABBR_MONTHNAMES[mo.to_i]} #{dy.to_i}, #{yr}"
    end
  end

  def fuzzy_pretty_short(key)
    return nil if self[key].blank?

    yr = self[key][0..3]
    mo = self[key][4..5]

    if yr == "9999" && mo == "99"
      nil
    elsif mo == "99"
      yr
    else
      "#{Date::ABBR_MONTHNAMES[mo.to_i]} #{yr}"
    end
  end

  # def indication
  #   "indication"
  # end

  # def dose
  #   "dose"
  # end

  # def units
  #   "units"
  # end

  # def frequency
  #   "frequency"
  # end

  # Start date readers
  def start_date_fuzzy_yr_1
    @start_date_fuzzy_yr_1 ||= begin
      start_date_fuzzy[0] if start_date_fuzzy.present?
    end
  end

  def start_date_fuzzy_yr_2
    @start_date_fuzzy_yr_2 ||= begin
      start_date_fuzzy[1] if start_date_fuzzy.present?
    end
  end

  def start_date_fuzzy_yr_3
    @start_date_fuzzy_yr_3 ||= begin
      start_date_fuzzy[2] if start_date_fuzzy.present?
    end
  end

  def start_date_fuzzy_yr_4
    @start_date_fuzzy_yr_4 ||= begin
      start_date_fuzzy[3] if start_date_fuzzy.present?
    end
  end

  def start_date_fuzzy_mo_1
    @start_date_fuzzy_mo_1 ||= begin
      start_date_fuzzy[4] if start_date_fuzzy.present?
    end
  end

  def start_date_fuzzy_mo_2
    @start_date_fuzzy_mo_2 ||= begin
      start_date_fuzzy[5] if start_date_fuzzy.present?
    end
  end

  def start_date_fuzzy_dy_1
    @start_date_fuzzy_dy_1 ||= begin
      start_date_fuzzy[6] if start_date_fuzzy.present?
    end
  end

  def start_date_fuzzy_dy_2
    @start_date_fuzzy_dy_2 ||= begin
      start_date_fuzzy[7] if start_date_fuzzy.present?
    end
  end

  # Stop date readers
  def stop_date_fuzzy_yr_1
    @stop_date_fuzzy_yr_1 ||= begin
      stop_date_fuzzy[0] if stop_date_fuzzy.present?
    end
  end

  def stop_date_fuzzy_yr_2
    @stop_date_fuzzy_yr_2 ||= begin
      stop_date_fuzzy[1] if stop_date_fuzzy.present?
    end
  end

  def stop_date_fuzzy_yr_3
    @stop_date_fuzzy_yr_3 ||= begin
      stop_date_fuzzy[2] if stop_date_fuzzy.present?
    end
  end

  def stop_date_fuzzy_yr_4
    @stop_date_fuzzy_yr_4 ||= begin
      stop_date_fuzzy[3] if stop_date_fuzzy.present?
    end
  end

  def stop_date_fuzzy_mo_1
    @stop_date_fuzzy_mo_1 ||= begin
      stop_date_fuzzy[4] if stop_date_fuzzy.present?
    end
  end

  def stop_date_fuzzy_mo_2
    @stop_date_fuzzy_mo_2 ||= begin
      stop_date_fuzzy[5] if stop_date_fuzzy.present?
    end
  end

  def stop_date_fuzzy_dy_1
    @stop_date_fuzzy_dy_1 ||= begin
      stop_date_fuzzy[6] if stop_date_fuzzy.present?
    end
  end

  def stop_date_fuzzy_dy_2
    @stop_date_fuzzy_dy_2 ||= begin
      stop_date_fuzzy[7] if stop_date_fuzzy.present?
    end
  end

  def set_fuzzy_dates
    set_fuzzy_date(:start_date_fuzzy)
    set_fuzzy_date(:stop_date_fuzzy)
  end

  def set_fuzzy_date(key)
    # Don't set value if no fuzzy values are provided.
    return unless send("#{key}_edit") == "1"

    if digit?(send("#{key}_dy_1")) && digit?(send("#{key}_dy_2"))
      dys = "#{send("#{key}_dy_1")}#{send("#{key}_dy_2")}"
      dy = send("#{key}_dy_1").to_i * 10 + send("#{key}_dy_2").to_i
    end

    if digit?(send("#{key}_mo_1")) && digit?(send("#{key}_mo_2"))
      mos = "#{send("#{key}_mo_1")}#{send("#{key}_mo_2")}"
      mo = send("#{key}_mo_1").to_i * 10 + send("#{key}_mo_2").to_i
    end

    if digit?(send("#{key}_yr_1")) && digit?(send("#{key}_yr_2")) && digit?(send("#{key}_yr_3")) && digit?(send("#{key}_yr_4"))
      yrs = "#{send("#{key}_yr_1")}#{send("#{key}_yr_2")}#{send("#{key}_yr_3")}#{send("#{key}_yr_4")}"
      yr = send("#{key}_yr_1").to_i * 1000 + send("#{key}_yr_2").to_i * 100 + send("#{key}_yr_3").to_i * 10 + send("#{key}_yr_4").to_i
    end

    if dy.nil? && mo.nil? && yr.nil?
      self[key] = nil
      return
    end

    if yr == 9999  && mo == 99 && dy == 99
      date_string = "#{yrs}#{mos}#{dys}"
    elsif yr == 9999 && mo != 99 && dy != 99
      errors.add(:"#{key}_mo", "should be 99")
      errors.add(:"#{key}_dy", "should be 99")
      errors.add(key, "month and day should be 99 if year is unknown")
    elsif yr == 9999 && mo == 99 && dy.present?
      errors.add(:"#{key}_dy", "should be 99")
      errors.add(key, "day should be 99 if month and year are unknown")
    elsif yr == 9999 && mo.present?
      errors.add(:"#{key}_mo", "should be 99")
      errors.add(key, "month should be 99 if year is unknown")
    elsif mo == 99 && dy != 99
      errors.add(:"#{key}_dy", "should be 99")
      errors.add(key, "day should be 99 if month is unknown")
    elsif yr.present? && mo == 99 && dy == 99
      if yr <= Time.zone.today.year
        date_string = "#{yrs}#{mos}#{dys}"
      else
        errors.add(:"#{key}_yr", "can't be in future")
        errors.add(key, "can't be in future")
      end
    elsif yr.present? && mo.present? && dy == 99
      if yr < Time.zone.today.year && mo.in?(1..12) || yr == Time.zone.today.year && mo.in?(1..Time.zone.today.month)
        date_string = "#{yrs}#{mos}#{dys}"
      else
        errors.add(:"#{key}_yr", "can't be in future")
        errors.add(:"#{key}_mo", "can't be in future")
        errors.add(key, "can't be in future")
      end
    elsif dy.present? && mo.present? && yr.present?
      date = Date.strptime("#{yrs}#{mos}#{dys}", "%Y%m%d") rescue date = nil
      if date
        if date > Time.zone.today
          errors.add(:"#{key}_yr", "can't be in future")
          errors.add(:"#{key}_mo", "can't be in future")
          errors.add(:"#{key}_dy", "can't be in future")
          errors.add(key, "can't be in future")
        else
          date_string = "#{yrs}#{mos}#{dys}"
        end
      else
        errors.add(:"#{key}_yr", "is invalid")
        errors.add(:"#{key}_mo", "is invalid")
        errors.add(:"#{key}_dy", "is invalid")
        errors.add(key, "is invalid")
      end
    elsif yr.nil? || mo.nil? || dy.nil?
      errors.add(:"#{key}_yr", "can't be blank") if yr.nil?
      errors.add(:"#{key}_mo", "can't be blank") if mo.nil?
      errors.add(:"#{key}_dy", "can't be blank") if dy.nil?
      errors.add(key, "can't have blank fields")
    end

    self[key] = date_string
  end

  def digit?(value)
    !(/^\d$/ =~ value).nil?
  end

  def save_medication_variables!
    return if medication_variables.blank?

    medication_variables.each do |key, value|
      medication_variable = project.medication_variables.find_by(id: key)
      next unless medication_variable

      medication_value = medication_values.where(
        project: project, subject: subject, medication_variable: medication_variable
      ).first_or_create
      medication_value.update(value: value)
    end
  end
end
