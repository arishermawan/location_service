class CreateLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :locations do |t|
      t.string :address
      t.string :coordinate
      t.belongs_to :area, foreign_key: true

      t.timestamps
    end
  end
end
