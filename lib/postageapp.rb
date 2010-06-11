require 'net/http'
require 'net/https'
require 'postageapp/version'
require 'postageapp/configuration'

module PostageApp
  
  class << self
    
    # Configuration object. See PostageApp::Cofiguration
    attr_accessor :configuration
    
    # Call this method to modify your configuration
    # 
    # Example:
    #  PostageApp.configure do |config|
    #    config.api_key             = '1234567890abcdef'
    #    config.recipient_override  = 'test@test.test' if Rails.env.staging?
    #  end
    def self.configure
      self.configuration ||= Configuration.new
      yield configuration
    end
    
  end
end