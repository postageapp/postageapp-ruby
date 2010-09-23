require File.expand_path('../helper', __FILE__)

class ConfigurationTest < Test::Unit::TestCase
  
  def test_initialization_defaults
    config = PostageApp::Configuration.new
    
    assert_equal true,                      config.secure
    assert_equal nil,                       config.api_key
    assert_equal 'https',                   config.protocol
    assert_equal 'api.postageapp.com',      config.host
    assert_equal 443,                       config.port
    assert_equal nil,                       config.proxy_host
    assert_equal nil,                       config.proxy_port
    assert_equal nil,                       config.proxy_user
    assert_equal nil,                       config.proxy_pass
    assert_equal 5,                         config.http_open_timeout
    assert_equal 10,                        config.http_read_timeout
    assert_equal nil,                       config.recipient_override
    assert_equal %w( send_message ),        config.requests_to_resend
    assert_equal nil,                       config.project_root
    assert_equal 'production',              config.environment
    assert_equal nil,                       config.logger
    assert_equal 'undefined framework',     config.framework
  end
  
  def test_initialization_overrides
    config = PostageApp::Configuration.new
    
    config.protocol = 'http'
    config.port     = 999
    
    assert_equal 'http',  config.protocol
    assert_equal 999,     config.port
  end
  
  def test_initialization_for_secure
    config = PostageApp::Configuration.new
    
    config.secure = true
    assert_equal true,    config.secure
    assert_equal 'https', config.protocol
    assert_equal 443,     config.port
    
    assert config.secure?
  end
  
  def test_initialization_for_insecure
    config = PostageApp::Configuration.new
    
    config.secure = false
    assert_equal false,   config.secure
    assert_equal 'http',  config.protocol
    assert_equal 80,      config.port
    
    assert !config.secure?
  end
  
  def test_initialization_with_env_api_key
    ENV['POSTAGEAPP_API_KEY'] = 'env_api_key'
    
    config = PostageApp::Configuration.new
    assert_equal 'env_api_key', config.api_key
    
    config.api_key = 'config_api_key'
    assert_equal 'config_api_key', config.api_key
    
    ENV['POSTAGEAPP_API_KEY'] = nil # must unset for other methods to run properly
  end
  
  def test_method_url
    config = PostageApp::Configuration.new
    
    config.host = 'api.postageapp.com'
    assert_equal 'https://api.postageapp.com:443', config.url
  end
  
end