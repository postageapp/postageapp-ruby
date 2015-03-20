require 'postageapp'

if (defined?(ActionMailer))
  require 'postageapp/mailer'

  # Register as a delivery method with ActionMailer
  ActionMailer::Base.add_delivery_method(
    :postageapp,
    PostageApp::Mail::DeliveryMethod
  )
end

class PostageApp::Railtie < Rails::Railtie
  config.after_initialize do
    PostageApp.configure do |config|
      if (defined?(::Rails.version))
        config.framework = "Rails #{::Rails.version}"
      end

      if (defined?(::Rails.root))
        config.project_root = ::Rails.root
      end

      if (defined?(::Rails.env))
        config.environment  = ::Rails.env
      end
    end
  end
end
