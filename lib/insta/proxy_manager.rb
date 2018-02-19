require 'securerandom'

class ProxyManager
  attr_reader :proxys
  attr_writer :proxys

  def initialize(proxys = [])
    proxys.each do |proxy|
      proxy[:id] = SecureRandom.uuid
      proxy[:last_use] = nil
    end
    @proxys = proxys
  end

  def next
    return nil if @proxys.nil?
    next_proxy = @proxys.sort_by { |proxy| proxy[:last_use] }.first
    next_proxy[:last_use] = Time.now
    next_proxy
  end
end
