# frozen_string_literal: true

# Allows SheetVariable and Grid to share similar methods, including storing
# checkbox responses, file uploads, and domain values.
module Valuable
  extend ActiveSupport::Concern

  included do
    # Scopes
    def self.pluck_domain_option_value_or_value
      left_outer_joins(:domain_option)
        .pluck("domain_options.value", :value)
        .collect { |v1, v2| v1 || v2 }
    end

    # Validations
    validates :variable_id, presence: true

    # Relationships
    belongs_to :variable
    has_many :responses

    mount_uploader :response_file, GenericUploader
  end
end
