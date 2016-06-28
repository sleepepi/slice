class RemoveEmailFieldsFromDesigns < ActiveRecord::Migration[4.2]
  def up
    remove_column :designs, :email_subject_template
    remove_column :designs, :email_template
  end

  def down
    add_column :designs, :email_template, :text
    add_column :designs, :email_subject_template, :string
  end
end
