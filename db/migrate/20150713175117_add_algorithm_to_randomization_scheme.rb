class AddAlgorithmToRandomizationScheme < ActiveRecord::Migration[4.2]
  def change
    add_column :randomization_schemes, :algorithm, :string, null: false, default: 'permuted-block'
  end
end
