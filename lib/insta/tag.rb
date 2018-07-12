module Insta
  module Tag
    def self.find(tag, data = {})
      endpoint = %[https://www.instagram.com/graphql/query/?query_hash=ded47faa9a1aaded10161a2ff32abb6b&variables={"tag_name":"#{tag}","first":42,"after":"#{data.dig(:end_cursor)}"}]
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
