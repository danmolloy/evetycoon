class CreateBakeTimes < ActiveRecord::Migration[5.0]
  def change
    create_table :bake_times do |t|
      t.belongs_to :item, index: true
      t.integer :activityID
      t.integer :time

      t.timestamps
    end
  end
end
