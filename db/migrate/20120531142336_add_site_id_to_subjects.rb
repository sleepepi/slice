class AddSiteIdToSubjects < ActiveRecord::Migration[4.2]
  def change
    add_column :subjects, :site_id, :integer
  end
end
