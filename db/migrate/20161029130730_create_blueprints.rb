class CreateBlueprints < ActiveRecord::Migration[5.0]
  def change
    create_table :blueprints do |t|
      t.belongs_to :item, index: true

      t.integer :quantity
      t.integer :time
      t.integer :maxProductionLimit
    end
  end
end
