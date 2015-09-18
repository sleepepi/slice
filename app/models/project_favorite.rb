class ProjectFavorite < ActiveRecord::Base
  # Model Relationships
  belongs_to :project
  belongs_to :user
end
