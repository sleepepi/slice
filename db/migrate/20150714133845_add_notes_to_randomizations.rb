class AddNotesToRandomizations < ActiveRecord::Migration
  def change
    add_column :randomizations, :notes, :text
  end
end
