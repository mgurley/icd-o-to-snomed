class Maps < ActiveRecord::Migration
  def change
    create_table :maps do |t|
      t.string  :icdo3_axis,      null: false
      t.string  :icdo3_code,      null: false
      t.string   :snomed_code,    null: false
      t.string   :refsetid,       null: false
      t.timestamps
    end
  end
end
