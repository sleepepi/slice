# frozen_string_literal: true

# Tracks sheet variable calculation errors.
class SheetError < ApplicationRecord
  belongs_to :project
  belongs_to :sheet, counter_cache: :errors_count
end
