class CreateCubes < ActiveRecord::Migration[5.2]
  def change
    create_table :cubes do |t|
      t.integer :tray_id
      t.integer :position
      t.text :text
      t.text :description
      t.string :cube_type
      t.timestamps
      t.index :tray_id
    end
  end
end
