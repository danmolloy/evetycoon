module MARKETDATA
  def marketdata(typeids, systemID=30000142)
    url = "http://eve-marketdata.com/api/item_prices2.json?"
    url += "char_name=Woofsie"
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
end
