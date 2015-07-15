class AddMinimizationColumnsToRandomizations < ActiveRecord::Migration
  def change
    add_column :randomizations, :dice_roll, :integer
    add_column :randomizations, :dice_roll_cutoff, :integer
    add_column :randomizations, :past_distributions, :text
    add_column :randomizations, :weighted_eligible_arms, :text
  end
end
