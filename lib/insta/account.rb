module Insta
  module Account
    def self.login(user, config = Insta::Configuration.new)
      request = Insta::API.http(
        url: CONSTANTS::URL + 'accounts/login/',
        method: 'POST',
        user: user,
        body: format(
          'ig_sig_key_version=4&signed_body=%s',
          Insta::API.generate_signature(
            device_id: user.device_id,
            login_attempt_user: 0, password: user.password, username: user.username,
            _csrftoken: 'missing', _uuid: Insta::API.generate_uuid
          ))
      )
      json_body = JSON.parse request.body
      logged_in_user = json_body['logged_in_user']
      user.data = {
        id: logged_in_user['pk'],
        full_name: logged_in_user['full_name'],
        is_private: logged_in_user['is_private'],
        profile_pic_url: logged_in_user['profile_pic_url'],
        profile_pic_id: logged_in_user['profile_pic_id'],
        is_verified: logged_in_user['is_verified'],
        is_business: logged_in_user['is_business']
      }
      cookies_array = []
      all_cookies = request.get_fields('set-cookie')
      all_cookies.each do |cookie|
        cookies_array.push(cookie.split('; ')[0])
      end
      cookies = cookies_array.join('; ')
      user.config = config
      user.session = cookies
    end

    def self.search_for_user_graphql(user, username, data)
      endpoint = "https://www.instagram.com/#{username}/?__a=1"
      proxies = Insta::ProxyManager.new data[:proxies] unless data[:proxies].nil?
      result = Insta::API.http(
        url: endpoint,
        method: 'GET',
        user: user,
        proxy: proxies&.next
      )
      response = JSON.parse result.body, symbolize_names: true
      return nil unless response[:user].any?
      {
        profile_id: response[:user][:id],
        external_url: response[:user][:external_url],
        followers: response[:user][:followed_by][:count],
        following: response[:user][:follows][:count],
        full_name: response[:user][:full_name],
        avatar_url: response[:user][:profile_pic_url],
        avatar_url_hd: response[:user][:profile_pic_url_hd],
        username: response[:user][:username],
        biography: response[:user][:biography],
        verified: response[:user][:is_verified],
        medias_count: response[:user][:media][:count],
        is_private: response[:user][:is_private]
      }
    end

    def self.by_id(user, profile_id, data)
      rank_token = Insta::API.generate_rank_token user.session.scan(/ds_user_id=([\d]+);/)[0][0]
      endpoint = "https://i.instagram.com/api/v1/users/#{profile_id}/info/"
      proxies = Insta::ProxyManager.new data[:proxies] unless data[:proxies].nil?
      param = format('?is_typehead=true&rank_token=%s', rank_token)
      result = Insta::API.http(
        url: endpoint + param,
        method: 'GET',
        user: user,
        proxy: proxies&.next
      )

      response = JSON.parse result.body, symbolize_names: true

      return nil unless response[:user].any?
      {
        profile_id: response[:user][:id],
        external_url: response[:user][:external_url],
        followers: response[:user][:follower_count],
        following: response[:user][:following_count],
        full_name: response[:user][:full_name],
        avatar_url: response[:user][:hd_profile_pic_url_info][:url],
        avatar_url_hd: response[:user][:hd_profile_pic_url_info][:url],
        username: response[:user][:username],
        biography: response[:user][:biography],
        verified: response[:user][:is_verified],
        medias_count: response[:user][:media_count],
        is_private: response[:user][:is_private],
        phone: response[:user][:contact_phone_number],
        email: response[:user][:public_email]
      }
    end

    def self.search_for_user(user, username, data)
      rank_token = Insta::API.generate_rank_token user.session.scan(/ds_user_id=([\d]+);/)[0][0]
      endpoint = 'https://i.instagram.com/api/v1/users/search/'
      proxies = Insta::ProxyManager.new data[:proxies] unless data[:proxies].nil?
      param = format('?is_typehead=true&q=%s&rank_token=%s', username, rank_token)
      result = Insta::API.http(
        url: endpoint + param,
        method: 'GET',
        user: user,
        proxy: proxies&.next
      )

      json_result = JSON.parse result.body
      if json_result['num_results'] > 0
        user_result = json_result['users'][0]
        user_object = Insta::User.new username, nil
        user_object.data = {
          id: user_result['pk'],
          full_name: user_result['full_name'],
          is_private: user_result['is_prive'],
          profile_pic_url: user_result['profile_pic_url'],
          profile_pic_id: user_result['profile_pic_id'],
          is_verified: user_result['is_verified'],
          is_business: user_result['is_business']
        }
        user_object.session = user.session
        user_object
      end
    end
  end
end
