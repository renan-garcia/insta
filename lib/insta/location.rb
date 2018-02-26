module Insta
  module Location
    def self.by_id(user, location_id, data)
      user_id = (!data[:id].nil? ? data[:id] : user.data[:id])
      rank_token = Insta::API.generate_rank_token user.session.scan(/ds_user_id=([\d]+);/)[0][0]
      endpoint = %Q[https://www.instagram.com/graphql/query/?query_id=17865274345132052&variables={"id":"#{location_id}","first":42,"after":"#{data.dig(:end_cursor)}"}]
      proxies = Insta::ProxyManager.new data[:proxies] unless data[:proxies].nil?
      result = Insta::API.http(
        url: endpoint,
        method: 'GET',
        user: user,
        proxy: proxies&.next
      )

      JSON.parse result.body
    end
  end
end
