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

require_relative './postageapp/env'

if (PostageApp::Env.rails?)
  require_relative './postageapp/engine'
  # require 'postageapp/ingresses/postage_app'
end

require_relative './postageapp/configuration'
require_relative './postageapp/diagnostics'
require_relative './postageapp/failed_request'
require_relative './postageapp/http'
require_relative './postageapp/logger'
require_relative './postageapp/request'
require_relative './postageapp/response'
require_relative './postageapp/mail'
require_relative './postageapp/mail/delivery_method'
require_relative './postageapp/utils'

if (defined?(Rails::Railtie))
  require_relative './postageapp/rails/railtie'
end

require_relative './postageapp/mail/extensions'

if (defined?(::Mail))
  PostageApp::Mail::Extensions.install!
end
