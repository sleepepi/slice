class AddSubjectCodeFormatToSites < ActiveRecord::Migration
  def change
    add_column :sites, :subject_code_format, :string
  end
end
