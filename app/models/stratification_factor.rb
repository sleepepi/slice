class StratificationFactor < ActiveRecord::Base
  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates :name, uniqueness: { case_sensitive: false, scope: [:deleted, :project_id, :randomization_scheme_id] }, presence: true
  validates :user_id, :project_id, :randomization_scheme_id, presence: true
  validates :stratifies_by_site, uniqueness: { scope: [:deleted, :project_id, :randomization_scheme_id] }, if: :stratifies_by_site

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :randomization_scheme
  has_many :stratification_factor_options, -> { where deleted: false }

  # Model Methods

  def option_hashes
    if stratifies_by_site?
      project.sites.order(:name).collect { |s| { stratification_factor_id: id, site_id: s.id, extra: true } }
    else
      stratification_factor_options.collect { |sfo| { stratification_factor_id: id, stratification_factor_option_id: sfo.id, extra: false } }
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
