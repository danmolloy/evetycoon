class CreateRecipies < ActiveRecord::Migration[5.0]
  def change
    create_table :recipies do |t|
      t.belongs_to :item, index: true
      t.integer :materialTypeID
      t.integer :quantity

      t.timestamps
    end
  end
end
