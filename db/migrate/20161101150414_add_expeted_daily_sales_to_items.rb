class AddExpetedDailySalesToItems < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :expected_daily_sales, :integer
  end
end
