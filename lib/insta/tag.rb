module Insta
  module Tag
    def self.find(tag, data = {})
      endpoint = %Q[https://www.instagram.com/graphql/query/?query_id=17875800862117404&variables={"tag_name":"#{tag}","first":42,"after":"#{data.dig(:end_cursor)}"}]
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
