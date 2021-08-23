# frozen_string_literal: true

if (defined?(ActionMailbox) and defined?(ActionMailbox::BaseController))
  class ActionMailbox::Ingresses::PostageApp::InboundEmailsController < ActionMailbox::BaseController
    before_action :hmac_authenticate

    def create
      ActionMailbox::InboundEmail.create_and_extract_message_id!(message_param)

      head(:ok)

    rescue JSON::ParserError => e
      logger.error(e.message)

      head(:unprocessable_entity)
    end

  private
    def message_param
      params.require(:inbound_email).require(:message)
    end

    def hmac_authenticate
      return if (hmac_authenticated?)

      head(:unauthorized)
    end

    def hmac_authenticated?
      if (PostageApp.config.postback_secret.present?)
        ActiveSupport::SecurityUtils.secure_compare(
          request.headers["X-PostageApp-Signature"],
          hmac_signature(message_param, PostageApp.config.postback_secret)
        )
      else
        raise ArgumentError, <<~END.squish
          Missing required PostageApp "postback secret" which can be set as
          in the Rails Encypted Credentials, as POSTAGEAPP_API_POSTBACK_SECRET
          in the environment, or via a config/initializer script using the
          PostageApp.config method.
        END
      end
    end

  private
    def hmac_signature(*content)
      Base64.strict_encode64(
        OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, *content)
      )
    end
  end
end
