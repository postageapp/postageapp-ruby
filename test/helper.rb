require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'postageapp'
require 'postageapp/mailer'

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
  
  def mock_successful_send
    Net::HTTP.any_instance.stubs(:post).returns(Net::HTTPResponse.new(nil, nil, nil))
    Net::HTTPResponse.any_instance.stubs(:body).returns({
      :response => { 
        :uid    => 'md5_hash_uid',
        :status => 'ok'
      },
      :data => {
        :message => { :id => 999 }
      }
    }.to_json)
  end
  
end
