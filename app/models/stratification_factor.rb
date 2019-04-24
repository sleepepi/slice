# frozen_string_literal: true

# Provides options used to determine the list to which a subject is randomized.
class StratificationFactor < ApplicationRecord
  # Concerns
  include Calculable
  include Deletable

  # Scopes

  # Validations
  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false, scope: [:deleted, :project_id, :randomization_scheme_id] }
  validates :user_id, :project_id, :randomization_scheme_id,
            presence: true
  validates :stratifies_by_site,
            uniqueness: { scope: [:deleted, :project_id, :randomization_scheme_id] }, if: :stratifies_by_site

  # Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :randomization_scheme
  has_many :stratification_factor_options, -> { current }

  # Methods

  def option_hashes
    if stratifies_by_site?
      project.sites.order_number_and_name.collect { |s| { stratification_factor_id: id, site_id: s.id, extra: true } }
    else
      stratification_factor_options.order(:value).collect do |sfo|
        { stratification_factor_id: id, stratification_factor_option_id: sfo.id, extra: false }
      end
    end
  end

  def valid_values
    if stratifies_by_site?
      project.sites.pluck(:id)
    else
      stratification_factor_options.pluck(:id)
    end
  end
end
