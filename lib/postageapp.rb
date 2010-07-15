require 'net/http'
require 'net/https'
require 'digest/md5'

require 'json'

require 'postageapp/utils'
require 'postageapp/version'
require 'postageapp/configuration'
require 'postageapp/request'
require 'postageapp/response'

module PostageApp
  
  class Error < StandardError
  end
  
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
    
  end
end