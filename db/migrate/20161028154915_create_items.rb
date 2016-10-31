class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
      t.integer :groupID
      t.string :typeName
      t.float :volume
      t.integer :portionSize
      t.float :basePrice
      t.boolean :published
      t.integer :marketGroupID
      t.timestamps
    end
  end
end
