class CreateStations < ActiveRecord::Migration[5.0]
  def change
    create_table :stations do |t|
      t.belongs_to :system, index: true
      t.string :name


      t.timestamps
    end
  end
end
