class CreateAeDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :ae_documents do |t|
      t.bigint :project_id
      t.bigint :ae_adverse_event_id
      t.bigint :user_id
      t.string :file
      t.string :filename
      t.string :content_type
      t.bigint :byte_size, default: 0, null: false
      t.timestamps

      t.index :project_id
      t.index :ae_adverse_event_id
      t.index :user_id
      t.index :content_type
      t.index :byte_size
    end
  end
end
