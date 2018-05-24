# frozen_string_literal: true

# Tracks sheet variable calculation errors.
class SheetError < ApplicationRecord
  # Concerns
  include Searchable

  # Relationships
  belongs_to :project
  belongs_to :sheet, counter_cache: :errors_count


  # Methods
  def self.searchable_attributes
    %w(description)
  end
end
