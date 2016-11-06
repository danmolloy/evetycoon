class HomeController < ApplicationController

  #30002187 - amarr
  # 34 - trit
  # 35 - pye
  # 36 - mex
  # 37 - isogen
  # 38 - noxc
  # 39 - zydr
  # 40 - mega


  def index
    #get_sell_prices(Item.all.map{|i| i.id}, 30002187)
    # blueprints = Item.where('typeName LIKE ?', "%Blueprint%")
    # get_sell_prices_from_marketdata(blueprints.map{|i| i.id})

    tabulate_blueprint_profits

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

  def tabulate_blueprint_profits
    recipes = find_items_containing(34)
    #candidates = recipes.select {|i| i.metaGroupID == nil && i.volume <= 1000 && i.buildable? && i.blueprint.on_market?}
    candidates = recipes.select {|i|  i.buildable? && i.blueprint.on_market? && i.volume <= 2000}

    #override = nil
    #Provi
    override = {35 => 5.00,
                36 => 5.11,
                37 => 63.10,
                38 => 75.00,
                39 => 344.00,
                40 => 950.00
              }
    #Statin
    # override = {35 => 1.78,
    #             36 => 4,
    #             37 => 50,
    #             38 => 40,
    #             39 => 220,
    #             40 => 1000
    #           }
    @data_rows = calculate_profits(candidates, 30000142, override)
  end

  def calculate_profits(items, systemID=30000142, override=nil)
    data_rows = Array.new
    items.each do |item|
      cost = item.cost(systemID, override)
      build_cost = item.build_cost(systemID, override)
      row = Hash.new
      sell_price = cost*item.blueprint.quantity
      per_unit_profit = cost - build_cost/item.blueprint.quantity
      profit = sell_price - build_cost
      expected_sales = item.expected_weekly_sales
      build_time_hours = item.blueprint.time.to_f*0.45/3600
      row['name'] = item.typeName
      row['build_cost'] = build_cost.round(2)
      row['sell_price'] = sell_price.round(2)
      row['profit'] = (sell_price - build_cost).round(2)
      row['hourly_profit'] = (profit/build_time_hours).round(2)
      row['expected_weekly_sales'] = expected_sales
      row['expected_weekly_profit'] = (expected_sales*per_unit_profit).round(2)
      row['production_line_usage_hours'] = expected_sales*build_time_hours
      row['production_line_usage_percent'] = (expected_sales*build_time_hours/168)*100
      if expected_sales > 0
        row['weekly_profit_per_production_hour'] = ((expected_sales*per_unit_profit)/(expected_sales*build_time_hours)).round(2)
      else
        row['weekly_profit_per_production_hour'] = 0
      end
      data_rows << row
    end
    data_rows.sort! { |a, b| b['weekly_profit_per_production_hour'] <=> a['weekly_profit_per_production_hour']}
  end


  def find_items_containing(ingredient)
    #return all Items that use an ingredient
    Item.all.select {|i| i.recipe[:ingredients].include?(ingredient)}
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

  def marketdata(typeids, systemID=30000142)
    url = "http://eve-marketdata.com/api/item_prices2.json?"
    url += "char_name=Joar_Mendar"
    url += "&buysell=s"
    url += "&solarsystem_ids=#{systemID}"
    url += "&type_ids=#{typeids.shift}"
    typeids.each do |id|
      url += ",#{id}"
    end
    puts url
    tries = 3
    begin
      tries -= 1
      sleep(3)
      RestClient.get url
    rescue Exception => e
      if tries > 0
        retry
      else
        puts e
      end
    end
  end

  def marketstat(typeids, hours:24, minq:nil, systemID:30000142)
    url = "http://api.eve-central.com/api/marketstat/json?"
    url += "hours=#{hours}"
    url += "&minQ=#{minq}" if minq
    url += "&usesystem=#{systemID}"
    typeids.each do |id|
      url += "&typeid=#{id}"
    end
    puts url
    tries = 3
    begin
      tries -= 1
      sleep(3)
      RestClient.get url, headers: {'Character: ' => 'Joar Mendar',
                                    'Email: ' => 'danieljmolloy1@gmail.com'}
    rescue Exception => e
      if tries > 0
        retry
      else
        puts e
      end
    end
  end
end
