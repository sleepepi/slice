class AddMinimizationColumnsToRandomizations < ActiveRecord::Migration[4.2]
  def change
    add_column :randomizations, :dice_roll, :integer
    add_column :randomizations, :dice_roll_cutoff, :integer
    add_column :randomizations, :past_distributions, :text
    add_column :randomizations, :weighted_eligible_arms, :text
  end
end
