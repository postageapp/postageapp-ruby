require 'rubygems'

gem 'minitest'
require 'minitest/autorun'

gem 'minitest-reporters'
require 'minitest/reporters'

Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)

require 'fileutils'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

ENV['POSTAGEAPP_API_KEY'] ||= '__TEST_API_KEY__'

require 'mail'

require 'postageapp'
require 'postageapp/mailer'

require 'mocha/setup'
require 'with_environment'

# This fixes an issue in Rails 3.2.22.2 where HashWithIndifferentAccess isn't
# being loaded properly during testing.
if (defined?(ActiveSupport) and !defined?(HashWithIndifferentAccess))
  require 'active_support/hash_with_indifferent_access'
end

class MiniTest::Test
  include WithEnvironment

  def self.require_action_mailer(version)
    if (defined?(ActionMailer))
      if (ActionMailer::VERSION::MAJOR == version)
        return yield
      end
    end

    define_method(:test_skipped) do
      skip("Not testing against ActionMailer #{version}.x")
    end
  end

  def setup
    # Resetting to default configuration

    PostageApp.configure(:reset) do |config|
      config.requests_to_resend = %w( send_message )
      config.project_root = File.expand_path('../', __FILE__)
      config.logger = nil
      config.framework = 'Ruby [Test]'
    end

    if (defined?(ActionMailer))
      ActionMailer::Base.deliveries.clear
    end
  end
  
  def mock_successful_send(status = 'ok')
    Net::HTTP.any_instance.stubs(:post).returns(Net::HTTPResponse.new(nil, nil, nil))
    Net::HTTPResponse.any_instance.stubs(:body).returns({
      response: { 
        uid: 'sha1hashuid23456789012345678901234567890',
        status: status
      },
      data: {
        message: { id: 999 }
      }
    }.to_json)
  end
  
  def mock_failed_send
    Net::HTTP.any_instance.stubs(:post).returns(nil)
  end

  # Briefly substitutes a new object in place of an existing constant.
  def const_replace(name, object)
    original = Object.const_defined?(name) && Object.const_get(name)
    
    Object.send(:remove_const, name) if (original)
    Object.const_set(name, object)

    yield

  ensure
    Object.send(:remove_const, name)
    Object.const_set(name, original)
  end
end
