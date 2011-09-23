require 'net/http'
require 'uri'
require 'openssl'
class Helper
  def self.get_response url
    uri = URI.parse url
    http = Net::HTTP.new(uri.host, uri.port)
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
  def self.get_https_response url
    uri = URI.parse url
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if http.respond_to? :use_ssl
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if respond_to? :verify_mode

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

    def self.make_it_a_message sth
      reply = sth.is_a?( Array) ? sth : [ sth ]
      { 'message' => reply}
  end

end
