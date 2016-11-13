class AddInfoToItems < ActiveRecord::Migration[5.0]
  def change
    rename_column :items, :typeName, :name
    add_column :items, :categoryID, :integer
    add_column :items, :groupName, :string
    add_column :items, :categoryName, :string
    add_column :items, :marketGroupName, :string
    add_column :items, :parentTypeID, :integer
    add_column :items, :packagedVolume, :float
    add_column :items, :productionQuantity, :integer
    add_column :items, :productionTime, :integer
    add_column :items, :maxProductionLimit, :integer
  end
end
