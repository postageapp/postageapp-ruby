require 'postageapp'
require 'postageapp/mailer' if defined?(ActionMailer)

module PostageApp::Rails
  
  def self.initialize
    PostageApp.configure do |config|
      config.framework    = "Rails #{::Rails.version}"  if defined?(::Rails.version)
      config.project_root = ::Rails.root                if defined?(::Rails.root)
      config.environment  = ::Rails.env                 if defined?(::Rails.env)
    end
  end
end

PostageApp::Rails.initialize