class AddNumberToDesignImages < ActiveRecord::Migration[6.0]
  def change
    add_column :design_images, :number, :integer
    add_index :design_images, [:design_id, :number], unique: true
  end
end
