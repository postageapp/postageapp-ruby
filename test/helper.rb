require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'postageapp'

begin require 'redgreen' unless ENV['TM_FILEPATH']; rescue LoadError; end
require 'mocha'

class Test::Unit::TestCase
  
  def setup
    # resetting to default configuration
    PostageApp.configure do |config|
      config.secure                     = true
      config.host                       = 'api.postageapp.com'
      config.api_key                    = '1234567890abcdef'
      config.http_open_timeout          = 5
      config.http_read_timeout          = 10
      config.development_environments   = %w( test )
      config.failed_requests_to_capture = %w( send_message )
    end
  end
  
end
