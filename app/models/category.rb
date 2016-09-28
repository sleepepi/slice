# frozen_string_literal: true

# Categories allow designs on a project to be grouped together. A design can
# only belong to a single category. Additionally a category can be marked to
# only show designs for use with the adverse events module. These designs will
# not show up on a subject page as a choice, and will only show up while filling
# out an adverse event for the subject.
class Category < ApplicationRecord
  # Concerns
  include Searchable, Deletable

  # Model Validation
  validates :name, :user_id, :project_id, presence: true
  validates :slug, uniqueness: { scope: [:project_id, :deleted] },
                   format: { with: /\A[a-z][a-z0-9\-]*\Z/ },
                   allow_blank: true
  validates :position, numericality: { greater_than_or_equal_to: 0,
                                       only_integer: true }

  # Model Relationships
  belongs_to :project
  belongs_to :user
  has_many :designs, -> { current }

  # Model Methods

  def to_param
    slug.blank? ? id : slug
  end

  def self.find_by_param(input)
    find_by 'categories.slug = ? or categories.id = ?', input.to_s, input.to_i
  end
end
