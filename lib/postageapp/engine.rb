module PostageApp
  class Engine < ::Rails::Engine
    isolate_namespace PostageApp

    initializer 'postageapp' do |app|
      app.config.action_mailbox.ingress = :postage_app
    end
  end
end
