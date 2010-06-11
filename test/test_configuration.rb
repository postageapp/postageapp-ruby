require File.dirname(__FILE__) + '/helper'

class TestConfiguration < Test::Unit::TestCase
  
  def test_intitialization_defaults
    config = PostageApp::Configuration.new
    
    assert_equal true,                      config.secure
    assert_equal nil,                       config.api_key
    assert_equal 'https',                   config.protocol
    assert_equal %w( api.postageapp.com ),  config.hosts
    assert_equal 443,                       config.port
    assert_equal nil,                       config.proxy_host
    assert_equal nil,                       config.proxy_port
    assert_equal nil,                       config.proxy_user
    assert_equal nil,                       config.proxy_password
    assert_equal 2,                         config.http_open_timeout
    assert_equal 5,                         config.http_read_timeout
    assert_equal nil,                       config.recipient_override
    assert_equal %w( test ),                config.development_environments
    assert_equal %w( send_message ),        config.failed_requests_to_capture
    assert_equal nil,                       config.failed_requests_path
    assert_equal PostageApp::VERSION,       config.client_version
    assert_equal nil,                       config.platform
    assert_equal nil,                       config.logger
  end
  
  def test_initialization_overrides
    config = PostageApp::Configuration.new
    
    config.protocol = 'http'
    config.port     = 999
    
    assert_equal 'http',  config.protocol
    assert_equal 999,     config.port
  end
  
  def test_intitialization_for_secure
    config = PostageApp::Configuration.new
    
    config.secure = true
    assert_equal true,    config.secure
    assert_equal 'https', config.protocol
    assert_equal 443,     config.port
    
    assert config.secure?
  end
  
  def test_intialization_for_insecure
    config = PostageApp::Configuration.new
    
    config.secure = false
    assert_equal false,   config.secure
    assert_equal 'http',  config.protocol
    assert_equal 80,      config.port
    
    assert !config.secure?
  end
  
end