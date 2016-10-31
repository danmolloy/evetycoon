class Item < ApplicationRecord
  has_many :ingredients
  has_one :blueprint
  has_many :prices

  def recipe
    {time: self.blueprint&.time, quantity: self.blueprint&.quantity,
    ingredients: self.ingredients&.collect{|i| i.simple}.to_h}
  end

  def readable_recipe
    {time: self.blueprint&.time, quantity: self.blueprint&.quantity,
    ingredients: self.ingredients&.collect{|i| i.readable_simple}.to_h}
  end

  def cost(system_id=30000142, override=nil)
    if override && override.include?(self.id)
      override[self.id]
    else
      Price.find_by(item_id: self.id, systemID: system_id, order_type: 'sell').price
    end
  end

  def build_cost(system_id=30000142, override=nil)
    return nil unless self.buildable?
    ingredients = self.recipe[:ingredients]
    cost = 0
    ingredients.each_pair do |itemID, quantity|
      if override && override.include?(itemID)
        price = override[itemID]
      else
        price = Price.find_by(item_id: itemID, systemID: system_id, order_type: 'sell').price
      end
      cost += (price * quantity * 0.94)
    end
    cost
  end


  def buildable?
    self.blueprint ? true : false
  end
end
