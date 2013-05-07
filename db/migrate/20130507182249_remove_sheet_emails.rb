class RemoveSheetEmails < ActiveRecord::Migration
  def up
    drop_table :sheet_emails
  end

  def down
    create_table :sheet_emails do |t|
      t.integer :sheet_id
      t.integer :user_id
      t.string :email_to
      t.string :email_cc
      t.string :email_subject
      t.text :email_body
      t.string :email_pdf_file
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
