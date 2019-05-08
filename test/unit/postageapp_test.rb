require_relative '../helper'

class PostageAppTest < MiniTest::Test
  def test_method_configure
    PostageApp.configure do |config|
      config.api_key = 'abcdefg12345'
      config.host = 'test.test'
    end

    assert_equal 'abcdefg12345', PostageApp.configuration.api_key
    assert_equal 'test.test', PostageApp.configuration.host

  ensure
    PostageApp.configuration_reset!
  end

  def test_version
    assert PostageApp.version.match(/\A\d+\.\d+\.\d+\z/), -> {
      "%s is not a valid version number" % PostageApp.version.inspect
    }
  end
  
  def test_logger
    assert PostageApp.logger.is_a?(Logger)
  end
end
