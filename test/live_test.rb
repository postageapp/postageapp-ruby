require_relative './helper'

class LiveTest < MiniTest::Test
  # Note: Need access to a live PostageApp.com account
  # See helper.rb to set host / api key

  if (ENV['POSTAGEAPP_API_KEY'] and ENV['POSTAGEAPP_API_KEY'] != '__TEST_API_KEY__')
    def test_configuration
      config = PostageApp.config

      assert config
      assert_equal ENV['POSTAGEAPP_API_KEY'], config.api_key
    end

    def test_request_get_method_list
      request = PostageApp::Request.new(:get_method_list)
      response = request.send
      
      assert_equal 'PostageApp::Response', response.class.name
      assert_equal 'ok', response.status
      assert_match(/^\w{40}$/, response.uid)
      assert_nil response.message
      assert_equal(
        {
          'methods' => %w[
            get_account_info
            get_message_receipt
            get_message_transmissions
            get_messages
            get_method_list
            get_metrics
            get_project_info
            get_recipients_list
            get_suppression_list
            message_delivery_status
            message_status
            messages_history
            project_create
            project_destroy
            project_info
            send_message
            test_mail_server
            test_recipient
          ].join(', ')
        },
        response.data
      )
    end
    
    def test_request_send_message
      request = PostageApp::Request.new(
        :send_message,
        headers: {
          'from' => 'sender@example.com',
          'subject' => 'Test Message'
        },
        recipients: 'recipient@example.net',
        content: {
          'text/plain' => 'text content',
          'text/html' => 'html content'
        }
      )

      response = request.send

      assert_equal 'PostageApp::Response', response.class.name
      assert_equal 'ok', response.status

      assert_match(/^\w{40}$/, response.uid)
      assert_nil response.message
      assert_match(/\d+/, response.data['message']['id'].to_s)
      
      receipt = PostageApp::Request.new(
        :get_message_receipt,
        uid: response.uid
      ).send
      
      assert receipt.ok?
      
      receipt = PostageApp::Request.new(
        :get_message_receipt,
        uid: 'bogus'
      ).send

      assert receipt.not_found?
    end
    
    def test_request_non_existant_method
      request = PostageApp::Request.new(:non_existant)

      response = request.send

      assert_equal 'PostageApp::Response', response.class.name
      assert_equal 'call_error', response.status

      assert_match(/\A\w{40}$/, response.uid)
      assert_match(/\ARequest could not be processed/, response.message)
      assert_nil response.data
    end
    
    # Testable under ruby 1.9.2 Probably OK in production too... Probably
    # Lunchtime reading: http://ph7spot.com/musings/system-timer
    def test_request_timeout
      PostageApp.configuration.host = '127.0.0.255'

      request = PostageApp::Request.new(:get_method_list)

      response = request.send

      assert_equal 'PostageApp::Response', response.class.name
      assert_equal 'timeout', response.status
    end
    
    if (defined?(Rails))
      def test_deliver_with_custom_postage_variables
        response =
          if (ActionMailer::VERSION::MAJOR < 3)
            require File.expand_path('../mailer/action_mailer_2/notifier', __FILE__)

            Notifier.deliver_with_custom_postage_variables
          else
            require File.expand_path('../mailer/action_mailer_3/notifier', __FILE__)

            Notifier.with_custom_postage_variables.deliver
          end

        assert_equal 'ok', response.status
        assert_equal true, response.ok?
      end
    end
  else
    puts "\e[0m\e[31mSkipping #{File.basename(__FILE__)}\e[0m"

    def test_nothing
    end
  end
end
