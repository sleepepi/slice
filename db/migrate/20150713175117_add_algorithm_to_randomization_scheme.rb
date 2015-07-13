class AddAlgorithmToRandomizationScheme < ActiveRecord::Migration
  def change
    add_column :randomization_schemes, :algorithm, :string, null: false, default: 'permuted-block'
  end
end
