class CreateSystems < ActiveRecord::Migration[5.0]
  def change
    create_table :systems do |t|
      t.belongs_to :region, index: true
      t.string :name
      t.float :security


      t.timestamps
    end
  end
end
