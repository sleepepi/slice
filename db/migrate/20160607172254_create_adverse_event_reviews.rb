class CreateAdverseEventReviews < ActiveRecord::Migration
  def change
    create_table :adverse_event_reviews do |t|
      t.integer :adverse_event_id
      t.string :name
      t.text :comment

      t.timestamps null: false
    end

    add_index :adverse_event_reviews, :adverse_event_id
  end
end
