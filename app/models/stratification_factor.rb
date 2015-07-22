class StratificationFactor < ActiveRecord::Base

  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :name, :user_id, :project_id, :randomization_scheme_id
  validates_uniqueness_of :name, case_sensitive: false, scope: [:deleted, :project_id, :randomization_scheme_id]
  validates_uniqueness_of :stratifies_by_site, scope: [:deleted, :project_id, :randomization_scheme_id], if: :stratifies_by_site

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :randomization_scheme
  has_many :stratification_factor_options, -> { where deleted: false }

  # Model Methods

  def option_hashes
    if self.stratifies_by_site?
      self.project.sites.order(:name).collect{|s| { stratification_factor_id: self.id, site_id: s.id, extra: true } }
    else
      self.stratification_factor_options.collect{|sfo| { stratification_factor_id: self.id, stratification_factor_option_id: sfo.id, extra: false } }
    end
  end

  def valid_values
    if self.stratifies_by_site?
      self.project.sites.pluck(:id)
    else
      self.stratification_factor_options.pluck(:id)
    end
  end

end
