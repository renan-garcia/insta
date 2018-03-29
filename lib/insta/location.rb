module Insta
  module Location
    def self.find(location_id, data = {})
      endpoint = %Q[https://www.instagram.com/graphql/query/?query_id=17865274345132052&variables={"id":"#{location_id}","first":42,"after":"#{data.dig(:end_cursor)}"}]
      proxies = Insta::ProxyManager.new data[:proxies] unless data[:proxies].nil?
      result = Insta::API.http(
        url: endpoint,
        method: 'GET',
        proxy: proxies&.next
      )

      JSON.parse result.body
    end
  end
end
