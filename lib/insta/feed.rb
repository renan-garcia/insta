module Insta
  module Feed
    def self.user_media(user, data)
      user_id = (!data[:id].nil? ? data[:id] : user.data[:id])
      rank_token = Insta::API.generate_rank_token user.session.scan(/ds_user_id=([\d]+);/)[0][0]
      endpoint = "https://i.instagram.com/api/v1/feed/user/#{user_id}/"
      proxies = Insta::ProxyManager.new data[:proxies] unless data[:proxies].nil?
      param = "?rank_token=#{rank_token}" +
              (!data[:max_id].nil? ? '&max_id=' + data[:max_id] : '')
      result = Insta::API.http(
        url: endpoint + param,
        method: 'GET',
        user: user,
        proxy: proxies&.next
      )

      JSON.parse result.body
    end

    def self.user_media_graphql(user, data)
      user_id = (!data[:id].nil? ? data[:id] : user.data[:id])
      endpoint = "https://www.instagram.com/graphql/query/?query_id=17880160963012870&id=#{user_id}&first=80&after="
      proxies = Insta::ProxyManager.new data[:proxies] unless data[:proxies].nil?
      result = Insta::API.http(
        url: endpoint,
        method: 'GET',
        user: user,
        proxy: proxies&.next,
        desktop: true
      )

      JSON.parse result.body
    end

    def self.user_followers(user, data, limit)
      has_next_page = true
      followers = []
      user_id = (!data[:id].nil? ? data[:id] : user.data[:id])
      proxies = Insta::ProxyManager.new data[:proxies] unless data[:proxies].nil?
      data[:rank_token] = Insta::API.generate_rank_token user.session.scan(/ds_user_id=([\d]+);/)[0][0]
      while has_next_page && limit > followers.size
        response = user_followers_next_page(user, user_id, data, proxies)
        has_next_page = !response['next_max_id'].nil?
        data[:max_id] = response['next_max_id']
        followers += response['users']
      end
      limit.infinite? ? followers : followers[0...limit]
    end

    def self.user_followers_graphql(user, data, limit)
      has_next_page = true
      followers = []
      user_id = (!data[:id].nil? ? data[:id] : user.data[:id])
      proxies = Insta::ProxyManager.new data[:proxies] unless data[:proxies].nil?
      while has_next_page && limit > followers.size
        response = user_followers_graphql_next_page(user, user_id, data, proxies)
        has_next_page = response['data']['user']['edge_followed_by']['page_info']['has_next_page']
        data[:end_cursor] = response['data']['user']['edge_followed_by']['page_info']['end_cursor']
        followers += response['data']['user']['edge_followed_by']['edges']
      end
      limit.infinite? ? followers : followers[0...limit]
    end

    def self.user_followers_graphql_next_page(user, user_id, data, proxies)
      endpoint = "https://www.instagram.com/graphql/query/?query_id=17851374694183129&id=#{user_id}&first=5000"
      param = (!data[:end_cursor].nil? ? "&after=#{data[:end_cursor]}" : '')
      result = Insta::API.http(
        url: endpoint + param,
        method: 'GET',
        user: user,
        proxy: proxies&.next
      )
      JSON.parse result.body
    end

    def self.user_followers_next_page(user, user_id, data, proxies)
      endpoint = "https://i.instagram.com/api/v1/friendships/#{user_id}/followers/"
      param = "?rank_token=#{data[:rank_token]}" +
              (!data[:max_id].nil? ? '&max_id=' + data[:max_id] : '')
      result = Insta::API.http(
        url: endpoint + param,
        method: 'GET',
        user: user,
        proxy: proxies&.next
      )
      JSON.parse result.body
    end
  end
end
