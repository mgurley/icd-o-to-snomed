class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string   :name,         null: false
      t.string   :icdo3_code
      t.string   :level      
      t.timestamps
    end
  end
end
