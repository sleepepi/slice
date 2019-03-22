class AddCacheBustersToDesigns < ActiveRecord::Migration[6.0]
  def change
    add_column :designs, :pdf_cache_busted_at, :datetime
    add_column :designs, :coverage_cache_busted_at, :datetime
  end
end
