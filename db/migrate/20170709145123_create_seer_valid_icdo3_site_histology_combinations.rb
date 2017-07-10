class CreateSeerValidIcdo3SiteHistologyCombinations < ActiveRecord::Migration[5.1]
  def change
    create_table :seer_valid_icdo3_site_histology_combinations do |t|
      t.string  :icdo3_histology_code,        null: false
      t.string  :icdo3_site_code,             null: false
    end
  end
end
