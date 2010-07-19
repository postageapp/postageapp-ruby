# PostageApp::Mailer intergration with ActionMailer::Base
# However, it's not backwards compartible with ActionMailer 2 api.

class PostageApp::Mailer < ActionMailer::Base
  
  # Wrapper for creating attachments
  # Attachments sent to PostageApp are in the following format:
  #  'filename.ext' => {
  #    'content_type' => 'content/type',
  #    'content'      => 'base64_encoded_content'
  #   }
  class Attachments < ActiveSupport::HashWithIndifferentAccess
    
    def initialize(message)
      @_message = message
      @_message.arguments['attachments'] ||= { }
    end
    
    def []=(filename, attachment)
      default_content_type = MIME::Types.type_for(filename).first.content_type rescue ''
      if attachment.is_a?(Hash)
        content_type  = attachment['content_type'] || default_content_type
        content       = Base64.encode64(attachment['body'])
      else
        content_type  = default_content_type
        content       = Base64.encode64(attachment)
      end
      @_message.arguments['attachments'][filename] = {
        'content_type'  => content_type,
        'content'       => content
      }
    end
  end
  
  # In API call we can specify PostageApp template that will be used
  # to generate content of the message
  attr_accessor :postage_template
  
  # Hash of variables that will be used to inject into the content
  attr_accessor :postage_variables
  
  # Instead of initializing Mail object, we prepare PostageApp::Request
  def initialize(method_name = nil, *args)
    @_message = PostageApp::Request.new(:send_message)
    process(method_name, *args) if method_name
  end
  
  def postage_template(value)
    # todo
  end
  
  def postage_variables(variables = {})
    # todo
  end
  
  def attachments
    @_attachments ||= Attachments.new(@_message)
  end
  
  # Overriding method that prepares Mail object. This time we'll be 
  # contructing PostageApp::Request payload.
  def mail(headers = {}, &block)
    # Guard flag to prevent both the old and the new API from firing
    # Should be removed when old API is removed
    @mail_was_called = true
    m = @_message
    
    # At the beginning, do not consider class default for parts order neither content_type
    content_type = headers[:content_type]
    parts_order  = headers[:parts_order]
    
    # Call all the procs (if any)
    default_values = self.class.default.merge(self.class.default) do |k,v|
      v.respond_to?(:call) ? v.bind(self).call : v
    end
    
    # Handle defaults
    headers = headers.reverse_merge(default_values)
    headers[:subject] ||= default_i18n_subject
    
    # Set configure delivery behavior
    wrap_delivery_behavior!(headers.delete(:delivery_method))
    
    # Assign all headers except parts_order, content_type and body
    assignable = headers.except(:parts_order, :content_type, :body, :template_name, :template_path)
    m.arguments[:headers] = assignable
    
    # Render the templates and blocks
    responses, explicit_order = collect_responses_and_parts_order(headers, &block)
    create_parts_from_responses(m, responses)
    
    m
  end
  
protected

  def create_parts_from_responses(m, responses) #:nodoc:
    content = m.arguments['content'] ||= {}
    responses.each do |part|
      content[part[:content_type]] = part[:body]
    end
  end
  
end