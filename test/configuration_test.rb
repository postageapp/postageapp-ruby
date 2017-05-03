require_relative './helper'

class ConfigurationTest < MiniTest::Test
  def test_initialization_defaults
    config = PostageApp::Configuration.new

    assert_equal true, config.secure

    if (ENV['POSTAGEAPP_API_KEY'])
      assert_equal ENV['POSTAGEAPP_API_KEY'], config.api_key
    end

    assert_equal 'https', config.scheme
    assert_equal ENV['POSTAGEAPP_API_HOST'] || 'api.postageapp.com', config.host
    assert_equal 443, config.port

    assert_nil config.proxy_host
    assert_equal 1080, config.proxy_port
    assert_nil config.proxy_user
    assert_nil config.proxy_pass

    assert_equal 5, config.http_open_timeout
    assert_equal 10, config.http_read_timeout
    assert_nil config.recipient_override
    assert_equal %w( send_message ), config.requests_to_resend
    assert_nil config.project_root
    assert_equal 'production', config.environment
    assert_nil config.logger
    assert_equal 'Ruby', config.framework
  end
  
  def test_initialization_overrides
    config = PostageApp::Configuration.new
    
    config.scheme = 'http'
    config.port = 999
    
    assert_equal 'http', config.scheme
    assert_equal 999, config.port
  end
  
  def test_initialization_for_secure
    config = PostageApp::Configuration.new
    
    config.secure = true

    assert_equal true, config.secure
    assert_equal 'https', config.scheme
    assert_equal 443, config.port
    
    assert_equal true, config.secure?
    assert_equal true, config.port_default?
  end
  
  def test_initialization_for_insecure
    config = PostageApp::Configuration.new
    
    config.secure = false
    assert_equal false, config.secure
    assert_equal 'http', config.scheme
    assert_equal 80, config.port
    
    assert !config.secure?
  end
  
  def test_initialization_with_env_api_key
    with_environment('POSTAGEAPP_API_KEY' => 'env_api_key') do
      config = PostageApp::Configuration.new

      assert_equal 'env_api_key', config.api_key
      
      config.api_key = 'config_api_key'
      assert_equal 'config_api_key', config.api_key
    end
  end
  
  def test_method_url
    config = PostageApp::Configuration.new
    
    config.host = 'api.postageapp.com'

    assert_equal true, config.port_default?

    assert_equal 'https://api.postageapp.com', config.url
  end
end
