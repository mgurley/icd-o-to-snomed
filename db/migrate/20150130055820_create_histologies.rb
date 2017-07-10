class CreateHistologies < ActiveRecord::Migration
  def change
    create_table :histologies do |t|
      t.string   :name,                 null: false
      t.string   :icdo3_code
      t.timestamps
    end
  end
end
