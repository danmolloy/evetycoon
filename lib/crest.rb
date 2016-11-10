module CREST

  def self.get_url(url, headers:true)
    tries = 3
    begin
      tries -= 1
      response = RestClient.get url, headers: {'Character: ' => 'Woofsie',
                                    'Email: ' => 'woofsie@gmail.com'}

      if headers
        response
      else
        ActiveSupport::JSON.decode(response.body)
      end
    rescue Exception => e
      if tries > 0
        retry
      else
        raise e
      end
    end
  end
  def self.get_relative(path, headers:false)
    unless headers
      ActiveSupport::JSON.decode(get_url("https://crest-tq.eveonline.com#{path}").body)
    else
      get_url("https://crest-tq.eveonline.com#{path}")
    end
  end

  def self.sell_ratio(highPrice, lowPrice, avgPrice)
    highDelta = highPrice.to_f - avgPrice.to_f
    lowDelta = avgPrice.to_f - lowPrice.to_f

    ratio = lowDelta/(highDelta + lowDelta)
    ratio = 1 if ratio.nan?
    return ratio
  end

  def self.get_root(headers:false)
    unless headers
      ActiveSupport::JSON.decode(get_url("https://crest-tq.eveonline.com/").body)
    else
      get_url("https://crest-tq.eveonline.com/")
    end
  end

  def self.daily_sales(typeid, region:10000002, days:30)
    history = get_market_history(typeid, region:region)
    sell_volumes = []

    history.last(days).each do |day|
      sell_volumes << day['volume']*sell_ratio(day['highPrice'], day['lowPrice'],day['avgPrice'])
    end
    if sell_volumes.empty?
       0
    else
      (sell_volumes.reduce(:+)/sell_volumes.count).round
    end
  end

  def self.get_orders(typeid, region:10000002, type: 'sell', filtered: true)
    raw = get_relative("/market/#{region}/orders/#{type}/?type=https://crest-tq.eveonline.com/inventory/types/#{typeid}/")['items'].sort{|a, b| a['price'] <=> b['price']}
    if filtered
      hub_stations = [60003760, 60008494, 60004588, 60011866, 60005686, 60011740]
      raw.select do |order|
        hub_stations.include?(order['location']['id'])
      end
    else
      raw
    end
  end

  def self.get_market_history(typeid, region:10000002)
    get_relative("/market/#{region}/history/?type=https://crest-tq.eveonline.com/inventory/types/#{typeid}/")['items']
  end
end
