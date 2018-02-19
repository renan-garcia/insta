require 'securerandom'

module Insta
  class ProxyManager
    attr_reader :proxies
    attr_writer :proxies

    def initialize(proxies = [])
      proxies.each do |proxy|
        proxy[:id] = SecureRandom.uuid
        proxy[:last_use] = nil
      end
      @proxies = proxies
    end

    def next
      return nil if @proxies.nil? || @proxies.empty?
      next_proxy = @proxies.sort_by { |proxy| proxy[:last_use] }.first
      next_proxy[:last_use] = Time.now
      next_proxy
    end
  end
end
