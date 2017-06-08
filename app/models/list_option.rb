# frozen_string_literal: true

# Tracks what stratification factor options are used to be part of the list.
class ListOption < ApplicationRecord
  # Relationships
  belongs_to :project, optional: true
  belongs_to :randomization_scheme, optional: true
  belongs_to :list
  belongs_to :option, class_name: "StratificationFactorOption", foreign_key: "option_id"

  # Methods
  def name
    option.label
  end
end
