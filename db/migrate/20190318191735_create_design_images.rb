class CreateDesignImages < ActiveRecord::Migration[6.0]
  def change
    create_table :design_images do |t|
      t.bigint :project_id
      t.bigint :design_id
      t.bigint :user_id
      t.string :file
      t.string :filename
      t.bigint :byte_size, null: false, default: 0
      t.string :content_type
      t.timestamps

      t.index :project_id
      t.index :design_id
      t.index :user_id
      t.index :byte_size
      t.index :content_type
    end
  end
end
