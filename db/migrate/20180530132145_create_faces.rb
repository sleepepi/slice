class CreateFaces < ActiveRecord::Migration[5.2]
  def change
    create_table :faces do |t|
      t.integer :cube_id
      t.integer :position
      t.text :text
      t.timestamps
      t.index :cube_id
    end
  end
end
