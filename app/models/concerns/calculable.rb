# frozen_string_literal: true

# Allows models to store variable references in calculations.
module Calculable
  extend ActiveSupport::Concern

  def readable_calculation
    calculation.to_s.gsub(/\#{(\d+)}/) do
      v = project.variables.find_by(id: $1)
      if v
        v.name
      else
        $1
      end
    end
  end

  def calculation=(calculation)
    calculation = calculation.to_s.gsub(/\w+/) do |word|
      v = project.variables.find_by(name: word)
      if v
        "\#{#{v.id}}"
      else
        word
      end
    end
    self[:calculation] = calculation.try(:strip)
  end
end
