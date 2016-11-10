class PricesController < ApplicationController
  def update
    recipes = Item.all.select {|i| i.recipe[:ingredients].include?(34)}

    samples = recipes.select {|i|  i.buildable? && i.blueprint.on_market? && i.volume > 10000
    @data = CSV::Table.new([CSV::Row.new(['Name', 'Volume', 'Price', 'Expected Sales'],
                 [nil, nil, nil, nil])])

    samples.each do |sample|

      @data << CSV::Row.new(['Name', 'Volume', 'Price', 'Expected Sales'],
                   [sample.typeName, sample.volume, sample.cost, sample.expected_weekly_sales])
    end
    render 'shared/_results'
  end

  def expected_sales(typeids)
    typeids.each do |type|
      jita_sales = CREST.daily_sales(type, region: 10000002)
      amarr_sales = CREST.daily_sales(type, region: 10000043)
      expected = (jita_sales*0.05 + amarr_sales*0.10)*7
      item = Item.find(type)
      item.update(expected_weekly_sales: expected.round)
      puts "#{item.typeName}: #{expected.round}"
    end
  end


    def get_sell_prices(typeids, systemID=30000142)
      # populate prices table with the sell percentile of given items in a system
      typeids.each_slice(50) do |ids|
        ActiveSupport::JSON.decode(marketstat(ids, systemID:systemID)).each do |item|
          price = Price.find_or_create_by(order_type: 'sell', item_id: item['sell']['forQuery']['types'][0], systemID: systemID)
          price.update(price: item['sell']['fivePercent'].to_f.round(2))
        end
      end
    end

    def get_sell_prices_from_marketdata(typeids, systemID=30000142)
      typeids.each_slice(10) do |ids|
        ActiveSupport::JSON.decode(marketdata(ids, systemID))['emd']['result'].each do |item|
          price = Price.find_or_create_by(order_type: 'sell', item_id: item['row']['typeID'], systemID: systemID)
          price.update(price: item['row']['price'].to_f.round(2))
        end
      end
    end
end
