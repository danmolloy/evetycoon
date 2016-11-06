class AddMetaGroupToItems < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :metaGroupID, :integer
    add_column :items, :metaGroupName, :string
  end
end
