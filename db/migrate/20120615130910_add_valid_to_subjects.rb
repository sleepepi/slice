class AddValidToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :valid, :boolean, null: false, default: false
  end
end
