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
      config.api_key            = '1234567890abcdef'
      config.secure             = true
      config.protocol           = 'https'
      config.host               = 'api.postageapp.com'
      config.port               = 443
      config.proxy_host         = nil
      config.proxy_port         = nil
      config.proxy_user         = nil
      config.proxy_pass         = nil
      config.http_open_timeout  = 5
      config.http_read_timeout  = 10
      config.recipient_override = nil
      config.requests_to_resend = %w( send_message )
      config.project_root       = File.expand_path('../', __FILE__)
      config.environment        = 'production'
      config.logger             = nil
      config.framework          = 'undefined framework'
    end
  end
  
  def mock_successful_send
    Net::HTTP.any_instance.stubs(:post).returns(Net::HTTPResponse.new(nil, nil, nil))
    Net::HTTPResponse.any_instance.stubs(:body).returns({
      :response => { 
        :uid    => 'sha1hashuid23456789012345678901234567890',
        :status => 'ok'
      },
      :data => {
        :message => { :id => 999 }
      }
    }.to_json)
  end
  
  def mock_failed_send
    Net::HTTP.any_instance.stubs(:post).returns(nil)
  end
  
end

# Setting up constants just for the duration of the test
module ConstantDefinitions
  
  def setup
    @defined_constants = []
  end
  
  def teardown
    @defined_constants.each do |constant|
      Object.__send__(:remove_const, constant)
    end
  end
  
  def define_constant(name, value)
    Object.const_set(name, value)
    @defined_constants << name
  end
  
end
