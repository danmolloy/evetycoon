module CENTRAL

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
      RestClient.get url, headers: {'Character: ' => 'Woofsie',
                                    'Email: ' => 'woofsie@gmail.com'}
    rescue Exception => e
      if tries > 0
        retry
      else
        puts e
        raise e
      end
    end
  end

end
