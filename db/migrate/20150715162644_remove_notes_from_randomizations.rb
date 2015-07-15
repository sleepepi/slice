class RemoveNotesFromRandomizations < ActiveRecord::Migration
  def change
    remove_column :randomizations, :notes, :text
  end
end
