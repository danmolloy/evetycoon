class RenameRecipiesToIngredients < ActiveRecord::Migration[5.0]
  def change
    rename_table :recipies, :ingredients
  end
end
