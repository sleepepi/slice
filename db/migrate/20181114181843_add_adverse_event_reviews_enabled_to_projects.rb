class AddAdverseEventReviewsEnabledToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :adverse_event_reviews_enabled, :boolean, null: false, default: false
  end
end
