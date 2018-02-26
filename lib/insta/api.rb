require 'openssl'
require 'base64'
require 'digest/md5'
require 'net/http'
require 'json'
require 'insta/user'
require 'insta/account'
require 'insta/feed'
require 'insta/configuration'
require 'insta/location'
require 'insta/tag'

module Insta
  module API
    def self.compute_hash(data)
      OpenSSL::HMAC.hexdigest OpenSSL::Digest.new('sha256'), CONSTANTS::PRIVATE_KEY[:SIG_KEY], data
    end

    def self.generate_uuid
      'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.gsub(/[xy]/) do |c|
        r = (Random.rand * 16).round | 0
        v = c == 'x' ? r : (r & 0x3 | 0x8)
        c.gsub(c, v.to_s(16))
      end.downcase
    end

    def self.create_md5(data)
      Digest::MD5.hexdigest(data).to_s
    end

    def self.generate_device_id
      timestamp = Time.now.to_i.to_s
      'android-' + create_md5(timestamp)[0..16]
    end

    def self.generate_signature(data)
      data = data.to_json
      compute_hash(data) + '.' + data
    end

    def self.http(args)
      args[:url] = URI.parse(args[:url])
      proxy = args[:proxy]
      if proxy
        http = Net::HTTP::Proxy(proxy.dig(:host), proxy.dig(:port), proxy.dig(:username), proxy.dig(:password)).new(args[:url].host, args[:url].port)
      else
        http = Net::HTTP.new(args[:url].host, args[:url].port)
      end

      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = nil
      if args[:method] == 'POST'
        request = Net::HTTP::Post.new(args[:url].path)
      elsif args[:method] == 'GET'
        request = Net::HTTP::Get.new(args[:url].path + (!args[:url].nil? ? '?' + args[:url].query : ''))
      end

      request.initialize_http_header(self.http_header(args))
      request.body = args.key?(:body) ? args[:body] : nil
      http.request(request)
    end

    def self.http_header(args)
      if args[:desktop]
        {
          :'User-Agent' => Insta::CONSTANTS::HEADER[:user_agent_desktop],
          :Accept => Insta::CONSTANTS::HEADER[:accept],
          :Cookie => (args.dig(:user)&.session.nil? ? '' : args.dig(:user)&.session)
        }
      else
        {
          :'User-Agent' => args.dig(:user)&.useragent,
          :Accept => Insta::CONSTANTS::HEADER[:accept],
          :'Accept-Encoding' => Insta::CONSTANTS::HEADER[:encoding],
          :'Accept-Language' => args.dig(:user)&.language,
          :'X-IG-Capabilities' => Insta::CONSTANTS::HEADER[:capabilities],
          :'X-IG-Connection-Type' => Insta::CONSTANTS::HEADER[:type],
          :Cookie => (args.dig(:user)&.session.nil? ? '' : args.dig(:user)&.session)
        }
      end
    end

    def self.generate_rank_token(pk)
      format('%s_%s', pk, Insta::API.generate_uuid)
    end
  end
end
