class RenameSalestoWeekly < ActiveRecord::Migration[5.0]
  def change
    rename_column :items, :expected_daily_sales, :expected_weekly_sales
  end
end
