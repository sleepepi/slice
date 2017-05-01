class AddTimeOfDayFormatToVariables < ActiveRecord::Migration[5.0]
  def change
    add_column :variables, :time_of_day_format, :string, null: false, default: '24hour'
  end
end
