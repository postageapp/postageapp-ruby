PostageApp::Engine.routes.draw do
  if (defined?(ActionMailbox))
    scope '/rails/action_mailbox', module: 'action_mailbox/ingresses' do
      post '/postageapp/inbound_emails' => 'postage_app/inbound_emails#create',
        as: :rails_postageapp_inbound_emails
    end
  end
end
