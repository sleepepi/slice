class Event < ActiveRecord::Base

  # Concerns
  include Searchable, Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :name, :project_id, :user_id
  validates_uniqueness_of :name, scope: [ :project_id, :deleted ]
  validates_uniqueness_of :slug, scope: [ :project_id, :deleted ], allow_blank: true
  validates_format_of :slug, with: /\A[a-z][a-z0-9\-]*\Z/, allow_blank: true

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :event_designs, -> { order(:position) }
  has_many :designs, -> { where deleted: false }, through: :event_designs

  accepts_nested_attributes_for :event_designs, allow_destroy: true

  # Model Methods

  def to_param
    slug.blank? ? id : slug
  end

  def self.find_by_param(input)
    self.where("slug = ? or id = ?", input.to_s, input.to_i).first
  end

end
