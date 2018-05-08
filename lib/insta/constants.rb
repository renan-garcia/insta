module Insta
  module CONSTANTS
    PRIVATE_KEY = {
        SIG_KEY: '0443b39a54b05f064a4917a3d1da4d6524a3fb0878eacabf1424515051674daa'.freeze,
        SIG_VERSION: '4'.freeze,
        APP_VERSION: '10.33.0'.freeze
    }.freeze

    SLEEP_TIME = 5

    HEADER = {
      user_agent_desktop: 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36'.freeze,
      capabilities: '3QI='.freeze,
      type: 'WIFI'.freeze,
      host: 'i.instagram.com'.freeze,
      connection: 'Close'.freeze,
      encoding: 'gzip, deflate, sdch'.freeze,
      accept: '*/*'.freeze
    }

    URL = 'https://i.instagram.com/api/v1/'.freeze
  end
end