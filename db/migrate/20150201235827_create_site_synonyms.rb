class CreateSiteSynonyms < ActiveRecord::Migration
  def change
    create_table :site_synonyms do |t|
      t.integer  :site_id, null: false
      t.string   :name,    null: false
      t.timestamps
    end
  end
end