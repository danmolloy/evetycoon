class Ingredient < ApplicationRecord
  belongs_to :item

  def simple
    [self.materialTypeID, self.quantity]
  end

  def readable_simple
    [Item.find_by_id(self.materialTypeID)&.typeName, self.quantity]
  end
end
