class AddAllowWeekendsToRandomizationSchemes < ActiveRecord::Migration[6.0]
  def change
    add_column :randomization_schemes, :allow_tasks_on_weekends, :boolean, null: false, default: false
  end
end
