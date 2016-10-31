class Blueprint < ApplicationRecord
  belongs_to  :item

  def on_market?
    Item.exists?(self.id) && Item.find(self.id).cost > 0 ? true : false
  end


end
