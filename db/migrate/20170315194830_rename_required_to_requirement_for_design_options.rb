class RenameRequiredToRequirementForDesignOptions < ActiveRecord::Migration[5.0]
  def change
    rename_column :design_options, :required, :requirement
  end
end
