class CreateCombinationMaps < ActiveRecord::Migration
  def change
    create_table :combination_maps do |t|
      t.string  :icdo3_histology_code,        null: false
      t.string  :icdo3_site_code,             null: false
      t.string  :refsetid,                    null: true
      t.string  :snomed_histology_code,       null: true
      t.string  :snomed_site_code,            null: true
      t.string  :snomed_precoordinated_code,  null: true
      t.timestamps
    end
  end
end