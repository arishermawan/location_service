class CreateAreas < ActiveRecord::Migration[5.1]
  def change
    create_table :areas do |t|
      t.string :name
      t.string :queue, default: "[]"

      t.timestamps
    end
  end
end
