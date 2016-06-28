class AddNotesToRandomizations < ActiveRecord::Migration[4.2]
  def change
    add_column :randomizations, :notes, :text
  end
end
