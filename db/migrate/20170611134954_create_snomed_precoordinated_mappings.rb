class CreateSnomedPrecoordinatedMappings < ActiveRecord::Migration
  def change
    create_table :snomed_precoordinated_mappings do |t|
      t.string  :conceptid,                   null: false
      t.string  :histology_destinationid,     null: false
      t.string  :site_destinationid,          null: false
      t.timestamps
    end
  end
end