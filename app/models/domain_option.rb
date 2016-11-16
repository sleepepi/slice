# frozen_string_literal: true

# Defines a single option for a domain.
class DomainOption < ApplicationRecord
  # Concerns
  include Squishable
  squish :name, :value

  # Validations
  validates :domain_id, :name, :value, presence: true
  validates :value, format: { with: /\A[\w\.-]*\Z/ },
                    uniqueness: { scope: :domain_id }

  # Relationships
  belongs_to :domain
  belongs_to :site

  # Methods

  def value_and_name
    "#{value}: #{name}"
  end

  # def update_from_hash!(option_hash, index)
  #   return if new_record?
  #   update(
  #     name: option_hash[:name],
  #     value: option_hash[:value],
  #     description: option_hash[:description],
  #     missing_code: option_hash[:missing_code],
  #     site_id: option_hash[:site_id],
  #     archived: option_hash[:archived],
  #     position: index
  #   )
  # end
end
