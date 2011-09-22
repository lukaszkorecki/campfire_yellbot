require 'net/http'
require 'openssl'

class Net::HTTP
  alias_method :origConnect, :connect
  def connect
    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
    origConnect
  end
end
