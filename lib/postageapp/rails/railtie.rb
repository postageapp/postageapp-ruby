require 'postageapp'
require 'postageapp/mailer' if defined?(ActionMailer)

class PostageApp::Railtie < Rails::Railtie
  
  config.after_initialize do
    PostageApp.configure do |config|
      config.framework    = "Rails #{::Rails.version}"  if defined?(::Rails.version)
      config.project_root = ::Rails.root                if defined?(::Rails.root)
      config.environment  = ::Rails.env                 if defined?(::Rails.env)
    end
  end
  
end