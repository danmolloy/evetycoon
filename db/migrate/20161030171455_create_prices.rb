class CreatePrices < ActiveRecord::Migration[5.0]
  def change
    create_table :prices do |t|
      t.belongs_to :item, index: true
      t.float :price
      t.integer :systemID
      t.string :order_type

      t.timestamps
    end
  end
end
