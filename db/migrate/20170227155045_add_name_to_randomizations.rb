class AddNameToRandomizations < ActiveRecord::Migration[5.0]
  def change
    add_column :randomizations, :name, :string
  end
end
