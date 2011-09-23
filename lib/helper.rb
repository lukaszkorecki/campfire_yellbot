require 'net/http'
require 'uri'
require 'openssl'
class Helper
  def self.get_response url, secure = false
    uri = URI.parse url
    http = Net::HTTP.new(uri.host, uri.port)
    if secure
      http.use_ssl = true if http.respond_to? :use_ssl
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if respond_to? :verify_mode
    end
    r = false
    begin
      http.request_get(uri.path)  do |res|
        r = res.body
      end
    rescue => e
      r  = e.message
    end

    r
  end
end
