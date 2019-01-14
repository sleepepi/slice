class CreateAeLogEntryAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :ae_log_entry_attachments do |t|
      t.bigint :ae_log_entry_id
      t.bigint :attachment_id
      t.string :attachment_type
      t.timestamps
      t.index [:ae_log_entry_id, :attachment_id], unique: true, name: "idx_log_attachment"
      t.index :attachment_type
    end
  end
end
