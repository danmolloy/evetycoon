class IncreaseIntLimitForSales < ActiveRecord::Migration[5.0]
  def change
    change_column :items, :expected_weekly_sales, :integer, limit: 8
  end
end
