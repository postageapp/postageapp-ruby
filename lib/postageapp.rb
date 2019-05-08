require 'net/http'
require 'net/https'
require 'digest'
require 'logger'
require 'fileutils'

require 'json'
require 'base64'

module PostageApp
  class Error < StandardError ; end
  
  # Call this method to modify your configuration
  # Example:
  #   PostageApp.configure do |config|
  #     config.api_key = '1234567890abcdef'
  #
  #     if Rails.env.staging?
  #       config.recipient_override = 'test@test.test' 
  #     end
  #   end
  # 
  # If you do not want/need to initialize the gem in this way, you can use the environment
  # variable POSTAGEAPP_API_KEY to set up your key.
  
  VERSION = File.read(File.expand_path('../VERSION', __dir__)).gsub(/\s/, '')

  def self.version
    VERSION
  end
  
  def self.configure(reset: false)
    if (reset)
      self.config_reset!
    end

    yield(self.config)
  end
  
  # Accessor for the PostageApp::Configuration object
  # Example use:
  #   PostageApp.configuration.api_key = '1234567890abcdef'
  def self.config
    @config ||= Configuration.new
  end

  def self.config_reset!
    @config = nil
  end

  class << self
    alias_method :configuration_reset!, :config_reset!
    alias_method :configuration, :config
  end
  
  # Logger for the plugin
  def self.logger
    @logger ||= begin
      config.logger || PostageApp::Logger.new(
        if (config.project_root)
          FileUtils.mkdir_p(File.join(File.expand_path(config.project_root), 'log'))
          File.join(config.project_root, "log/postageapp_#{config.environment}.log")
        else
          $stdout
        end
      )
    end
  end
end

require 'postageapp/env'

if (PostageApp::Env.rails?)
  require 'postageapp/engine'
  # require 'postageapp/ingresses/postage_app'
end

require 'postageapp/configuration'
require 'postageapp/diagnostics'
require 'postageapp/failed_request'
require 'postageapp/http'
require 'postageapp/logger'
require 'postageapp/request'
require 'postageapp/response'
require 'postageapp/mail'
require 'postageapp/mail/delivery_method'
require 'postageapp/utils'

if (defined?(Rails::Railtie))
  require 'postageapp/rails/railtie'
end

require 'postageapp/mail/extensions'

if (defined?(::Mail))
  PostageApp::Mail::Extensions.install!
end
