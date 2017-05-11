class AddDeletedIndicesToModels < ActiveRecord::Migration[5.0]
  def change
    add_index :adverse_event_comments, :deleted
    add_index :comments, :deleted
    add_index :designs, :deleted
    add_index :domains, :deleted
    add_index :events, :deleted
    add_index :exports, :deleted
    add_index :projects, :deleted
    add_index :sheets, :deleted
    add_index :sites, :deleted
    add_index :subjects, :deleted
    add_index :users, :deleted
    add_index :variables, :deleted
  end
end
