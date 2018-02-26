module Insta
  module Tag
    def self.find(user, tag, data)
      user_id = (!data[:id].nil? ? data[:id] : user.data[:id])
      rank_token = Insta::API.generate_rank_token user.session.scan(/ds_user_id=([\d]+);/)[0][0]
      endpoint = %Q[https://www.instagram.com/graphql/query/?query_id=17875800862117404&variables={"tag_name":"#{tag}","first":42,"after":"#{data.dig(:end_cursor)}"}]
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
