require 'postageapp'

if (defined?(ActionMailer))
  require 'postageapp/mailer' 
end

module PostageApp::Rails  
  def self.initialize
    PostageApp.configure do |config|
      if (defined?(::Rails.version))
        config.framework = "Rails #{::Rails.version}"
      end

      if (defined?(::Rails.root))
        config.project_root = ::Rails.root
      end

      if (defined?(::Rails.env))
        config.environment = ::Rails.env
      end
    end
  end
end

PostageApp::Rails.initialize
