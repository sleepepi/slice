class Schedule < ActiveRecord::Base
  serialize :items, Array

  # Concerns
  include Searchable, Deletable

  # Model Validation
  validates :project_id, :user_id, :name, presence: true
  validates :name, uniqueness: { scope: [:deleted, :project_id] }

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :subject_schedules

  # Model Methods

  def designs(ids)
    project.designs.where(id: ids).order(:name)
  end

  def sorted_items
    items.sort { |a, b| relative_size(a) <=> relative_size(b) }
  end

  private

  def relative_size(item_hash)
    interval = item_hash.symbolize_keys[:interval].to_i
    units = item_hash.symbolize_keys[:units]
    case units
    when 'business days'
      interval.send('days')
    else
      interval.send(units)
    end
  end
end
