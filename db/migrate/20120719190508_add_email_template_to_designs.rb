class AddEmailTemplateToDesigns < ActiveRecord::Migration
  def change
    add_column :designs, :email_template, :text
  end
end
