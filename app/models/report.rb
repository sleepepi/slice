# frozen_string_literal: true

class Report < ActiveRecord::Base
  serialize :options, Hash

  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates :user_id, :name, presence: true

  # Model Relationships
  belongs_to :user

  # Model Methods
  def design
    Design.current.find_by_id options[:design_id]
  end

  def project
    design ? design.project : nil
  end
end
