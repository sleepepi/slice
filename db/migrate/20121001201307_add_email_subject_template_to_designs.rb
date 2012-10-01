class AddEmailSubjectTemplateToDesigns < ActiveRecord::Migration
  def change
    add_column :designs, :email_subject_template, :string
  end
end
