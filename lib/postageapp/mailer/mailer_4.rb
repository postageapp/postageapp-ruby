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
#         to: recipient.email,
#         from: 'sender@test.test',
#         subject: 'Test Message'
#       )
#     end
#   end
#
# Postage::Mailer introduces a few mailer methods specific to Postage:
#
# * postageapp_template - template name that is defined in your PostageApp project
# * postageapp_variables - extra variables you want to send along with the message
#
# Sending email
#
#   # Create a PostageApp::Request object
#   request = Notifier.signup_notification(user) 
#   # Deliver the message and return a PostageApp::Response
#   response = request.deliver_now

class PostageApp::Mailer < ActionMailer::Base
  CONTENT_TYPE_MAP = {
    'html' => 'text/html',
    'text' => 'text/plain'
  }

  # Wrapper for creating attachments
  # Attachments sent to PostageApp are in the following format:
  #  'filename.ext' => {
  #    content_type: 'content/type',
  #    content: 'base64_encoded_content'
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

    if (method_name)
      process(method_name, *args)
    end
  end

  # Possible to define custom uid. Should be sufficiently unique
  def postageapp_uid(value = nil)
    if (value)
      @_message.uid = value
    else
      @_message.uid
    end
  end

  def postageapp_api_key(value = nil)
    if (value)
      @_message.api_key = value
    else
      @_message.api_key
    end
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
    @_mail_was_called = true
    m = @_message

    # Call all the procs (if any)
    class_default = self.class.default
    default_values = class_default.merge(self.class.default) do |k,v|
      v.respond_to?(:call) ? v.bind(self).call : v
    end

    # Handle defaults
    headers = headers.reverse_merge(default_values)

    # Set configure delivery behavior
    wrap_delivery_behavior!(
      headers.delete(:delivery_method),
      headers.delete(:delivery_method_options)
    )

    # Assigning recipients
    m.arguments['recipients'] = headers.delete(:to)

    # Assign all headers except parts_order, content_type and body
    assignable = headers.except(
      :parts_order,
      :content_type,
      :body,
      :template_name,
      :template_path
    )
    
    m.headers.merge!(assignable)

    # Render the templates and blocks
    responses = collect_responses(headers, &block)
    create_parts_from_responses(m, responses)

    m
  end

protected
  def each_template(paths, name, &block) #:nodoc:
    (lookup_context.find_all(name, paths) || [ ]).uniq do |t|
      t.formats
    end.each(&block)
  end

  def create_parts_from_responses(m, responses) #:nodoc:
    content = m.arguments['content'] ||= { }

    responses.each do |part|
      content_type = CONTENT_TYPE_MAP[part[:content_type]] || part[:content_type]
      content[content_type] = part[:body]
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
  def deliver_now
    inform_interceptors

    if (perform_deliveries)
      if (@delivery_method == Mail::TestMailer)
        @delivery_method.deliveries << self
      else
        self.send
      end
    end
  end
  alias_method :deliver, :deliver_now

  # Not 100% on this, but I need to assign this so I can properly handle deliver method
  def delivery_method(method = nil, settings = nil)
    @delivery_method = method
  end
end
