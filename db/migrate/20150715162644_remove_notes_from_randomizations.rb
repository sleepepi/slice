class RemoveNotesFromRandomizations < ActiveRecord::Migration[4.2]
  def change
    remove_column :randomizations, :notes, :text
  end
end
