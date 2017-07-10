class CreateHistologySynonyms < ActiveRecord::Migration
  def change
    create_table :histology_synonyms do |t|
      t.integer  :histology_id, null: false
      t.string   :name,         null: false
      t.timestamps
    end
  end
end
