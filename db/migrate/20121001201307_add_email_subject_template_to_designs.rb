class AddEmailSubjectTemplateToDesigns < ActiveRecord::Migration[4.2]
  def change
    add_column :designs, :email_subject_template, :string
  end
end
