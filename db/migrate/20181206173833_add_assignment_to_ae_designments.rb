class AddAssignmentToAeDesignments < ActiveRecord::Migration[5.2]
  def change
    add_column :ae_designments, :assignment, :string
    add_index :ae_designments, :assignment
  end
end
