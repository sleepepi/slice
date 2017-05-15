class RemoveBranchingLogicFromSections < ActiveRecord::Migration[5.0]
  def change
    remove_column :sections, :branching_logic, :text
  end
end
