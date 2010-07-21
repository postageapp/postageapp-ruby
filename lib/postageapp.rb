require 'net/http'
require 'net/https'
require 'digest/md5'
require 'logger'

require 'json'

require 'postageapp/utils'
require 'postageapp/version'
require 'postageapp/configuration'
require 'postageapp/logger'
require 'postageapp/request'
require 'postageapp/failed_request'
require 'postageapp/response'

module PostageApp
  
  class Error < StandardError ; end
  
  class << self
    
    # Accessor for the PostageApp::Configuration object
    attr_accessor :configuration
    
    # Call this method to modify your configuration
    # 
    # Example:
    #   PostageApp.configure do |config|
    #     config.api_key             = '1234567890abcdef'
    #     config.recipient_override  = 'test@test.test' if Rails.env.staging?
    #   end
    def configure
      self.configuration ||= Configuration.new
      yield self.configuration
    end
    
    # Logger for the plugin
    def logger
      raise Error, 'Need configuration to be set before logger can be used' if !configuration
      @logger ||= begin
        configuration.logger || PostageApp::Logger.new(
          if configuration.project_root
            FileUtils.mkdir_p(File.join(File.expand_path(configuration.project_root), 'log'))
            File.join(configuration.project_root, "log/postageapp_#{configuration.environment}.log")
          else
            STDOUT
          end
        )
      end
    end
    
  end
end

# Loading Rails hook
require 'postageapp/rails' if defined?(Rails)
