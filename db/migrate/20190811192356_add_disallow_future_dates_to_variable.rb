class AddDisallowFutureDatesToVariable < ActiveRecord::Migration[6.0]
  def change
    add_column :variables, :disallow_future_dates, :boolean, null: false, default: false
  end
end
