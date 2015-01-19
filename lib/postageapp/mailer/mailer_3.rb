# Postage::Mailer allows you to use/re-use existing mailers set up using
# ActionMailer. The only catch is to change inheritance from ActionMailer::Base
# to PostageApp::Mailer. Also don't forget to require 'postageapp/mailer'
#
# Here's an example of a valid PostageApp::Mailer class
#
#   require 'postageapp/mailer'
#
#   class Notifier < PostageApp::Mailer
#     def signup_notification(recipient)
#       mail(
#         :to       => recipient.email,
#         :from     => 'sender@test.test',
#         :subject  => 'Test Message'
#       )
#     end
#   end
#
# Postage::Mailer introduces a few mailer methods specific to Postage:
#
# * postageapp_template  - template name that is defined in your PostageApp project
# * postageapp_variables - extra variables you want to send along with the message
#
# Sending email
#
#   request = Notifier.signup_notification(user) # creates PostageApp::Request object
#   response = request.deliver # attempts to deliver the message and creates a PostageApp::Response

class PostageApp::Mailer < ActionMailer::Base
  # Wrapper for creating attachments
  # Attachments sent to PostageApp are in the following format:
  #  'filename.ext' => {
  #    'content_type' => 'content/type',
  #    'content'      => 'base64_encoded_content'
  #   }

  class Attachments < Hash
    def initialize(message)
      @_message = message

      message.arguments['attachments'] ||= { }
    end

    def []=(filename, attachment)
      default_content_type = MIME::Types.type_for(filename).first.content_type rescue ''

      case (attachment)
      when Hash
        content_type = attachment[:content_type] || default_content_type
        content = Base64.encode64(attachment[:body])
      else
        content_type = default_content_type
        content = Base64.encode64(attachment)
      end

      @_message.arguments['attachments'][filename] = {
        'content_type' => content_type,
        'content' => content
      }
    end
  end

  # Instead of initializing Mail object, we prepare PostageApp::Request
  def initialize(method_name = nil, *args)
    super()

    @_message = PostageApp::Request.new(:send_message)

    if method_name
      process(method_name, *args)
    end
  end

  # Possible to define custom uid. Should be sufficiently unique
  def postageapp_uid(value = nil)
    value ? @_message.uid = value : @_message.uid
  end

  def postageapp_api_key(value = nil)
    value ? @_message.api_key = value : @_message.api_key
  end

  # In API call we can specify PostageApp template that will be used
  # to generate content of the message
  def postageapp_template(value = nil)
    if (value)
      @_message.arguments['template'] = value
    else
      @_message.arguments['template']
    end
  end

  # Hash of variables that will be used to inject into the content
  def postageapp_variables(value = nil)
    if (value)
      @_message.arguments['variables'] = value
    else
      @_message.arguments['variables']
    end
  end

  def attachments
    @_attachments ||= Attachments.new(@_message)
  end

  # Override for headers assignment
  def headers(args = nil)
    @_message.headers(args)
  end

  # Overriding method that prepares Mail object. This time we'll be
  # contructing PostageApp::Request payload.
  def mail(headers = { }, &block)
    # Guard flag to prevent both the old and the new API from firing
    # Should be removed when old API is removed
    @mail_was_called = true
    m = @_message

    # At the beginning, do not consider class default for parts order neither content_type
    content_type = headers[:content_type]
    parts_order = headers[:parts_order]

    # Call all the procs (if any)
    default_values = self.class.default.merge(self.class.default) do |k,v|
      if (v.respond_to?(:call))
        v.bind(self).call
      else
        v
      end
    end

    # Handle defaults
    headers = headers.reverse_merge(default_values)

    # Set configure delivery behavior
    wrap_delivery_behavior!(headers.delete(:delivery_method))

    # Assigning recipients
    m.arguments['recipients'] = headers.delete(:to)

    # Assign all headers except parts_order, content_type and body
    assignable = headers.except(:parts_order, :content_type, :body, :template_name, :template_path)
    m.headers.merge!(assignable)

    # Render the templates and blocks
    responses, explicit_order = collect_responses_and_parts_order(headers, &block)
    create_parts_from_responses(m, responses)

    m
  end

protected
  def create_parts_from_responses(m, responses) #:nodoc:
    content = m.arguments['content'] ||= { }

    responses.each do |part|
      content[part[:content_type]] = part[:body]
    end
  end
end

# A set of methods that are useful when request needs to behave as Mail
class PostageApp::Request
  attr_accessor :delivery_handler
  attr_accessor :perform_deliveries
  attr_accessor :raise_delivery_errors

  def inform_interceptors
    Mail.inform_interceptors(self)
  end

  # Either doing an actual send, or passing it along to Mail::TestMailer
  # Probably not the best way as we're skipping way too many intermediate methods
  def deliver
    inform_interceptors

    if (perform_deliveries)
      if (@delivery_method == Mail::TestMailer)
        @delivery_method.deliveries << self
      else
        self.send
      end
    end
  end

  # Not 100% on this, but I need to assign this so I can properly handle deliver method
  def delivery_method(method = nil, settings = { })
    @delivery_method = method
  end
end
