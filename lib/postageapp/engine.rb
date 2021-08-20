module PostageApp
  class Engine < ::Rails::Engine
    isolate_namespace PostageApp

    initializer 'postageapp' do |app|
      if (app.config.respond_to?(:action_mailbox))
        app.config.action_mailbox.ingress = :postage_app
      end
    end
  end
end
