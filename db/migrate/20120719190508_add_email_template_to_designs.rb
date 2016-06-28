class AddEmailTemplateToDesigns < ActiveRecord::Migration[4.2]
  def change
    add_column :designs, :email_template, :text
  end
end
