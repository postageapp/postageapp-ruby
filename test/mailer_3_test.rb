require_relative './helper'

class Mailer3Test < MiniTest::Test
  require_action_mailer(3) do
    require File.expand_path('mailer/action_mailer_3/notifier', File.dirname(__FILE__))

    puts "\e[0m\e[32mRunning #{File.basename(__FILE__)} for action_mailer #{ActionMailer::VERSION::STRING}\e[0m"

    def test_create_with_no_content
      mail = Notifier.with_no_content

      assert_equal({ }, mail.arguments['content'])
    end

    def test_create_with_no_subject
      mail = Notifier.with_no_subject

      assert mail.arguments['headers'][:subject].nil?
    end

    def test_create_with_simple_view
      mail = Notifier.with_simple_view

      assert_equal 'with layout simple view content', mail.arguments['content']['text/html']
    end

    def test_create_with_text_only_view
      mail = Notifier.with_text_only_view

      assert_equal 'text content', mail.arguments['content']['text/plain']
    end

    def test_create_with_html_and_text_views
      mail = Notifier.with_html_and_text_views

      assert_equal 'text content', mail.arguments['content']['text/plain']
      assert_equal 'with layout html content', mail.arguments['content']['text/html']
    end

    def test_deliver_with_html_and_text_views
      mock_successful_send

      assert response = Notifier.with_html_and_text_views.deliver
      assert response.is_a?(PostageApp::Response)
      assert response.ok?
    end

    def test_create_with_body_and_attachment_as_file
      mail = Notifier.with_body_and_attachment_as_file

      assert_equal 'manual body text', mail.arguments['content']['text/html']
      assert_equal 'text/plain', mail.arguments['attachments']['sample_file.txt']['content_type']
      assert_equal "RmlsZSBjb250ZW50\n", mail.arguments['attachments']['sample_file.txt']['content']
    end

    def test_create_with_body_and_attachment_as_hash
      mail = Notifier.with_body_and_attachment_as_hash

      assert_equal 'manual body text', mail.arguments['content']['text/html']
      assert_equal 'text/rich', mail.arguments['attachments']['sample_file.txt']['content_type']
      assert_equal "RmlsZSBjb250ZW50\n", mail.arguments['attachments']['sample_file.txt']['content']
    end

    def test_create_with_custom_postage_variables
      mail = Notifier.with_custom_postage_variables

      args = mail.arguments_to_send

      assert_equal 'custom_uid', args['uid']
      assert_equal 'custom_api_key', args['api_key']

      args = args['arguments']

      assert_equal(
        {
          'test1@example.net' => { 'name' => 'Test 1' },
          'test2@example.net' => { 'name' => 'Test 2' }
        },
        args['recipients']
      )

      assert_equal 'test-template', args['template']
      assert_equal({ 'variable' => 'value' }, args['variables'])
      assert_equal 'CustomValue1', args['headers']['CustomHeader1']
      assert_equal 'CustomValue2', args['headers']['CustomHeader2']
      assert_equal 'text content', args['content']['text/plain']
      assert_equal 'with layout html content', args['content']['text/html']
    end

    def test_create_with_recipient_override
      PostageApp.configuration.recipient_override = 'override@example.net'

      assert mail = Notifier.with_html_and_text_views

      assert_equal 'recipient@example.net', mail.arguments['recipients']
      assert_equal 'override@example.net', mail.arguments_to_send['arguments']['recipient_override']
    end

    def test_deliver_for_test_mailer
      mail = Notifier.with_simple_view

      mail.delivery_method(Mail::TestMailer)
      mail.deliver

      assert_equal [ mail ], ActionMailer::Base.deliveries
    end

    def test_deliver_for_not_performing_deliveries_with_test_mailer
      mail = Notifier.with_simple_view

      mail.perform_deliveries = false
      mail.delivery_method(Mail::TestMailer)
      mail.deliver

      assert_equal [ ], ActionMailer::Base.deliveries
    end
  end
end
