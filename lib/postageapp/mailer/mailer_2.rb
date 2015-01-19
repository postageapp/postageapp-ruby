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
#       recipients  recipient.email_address
#       from        'system@example.com'
#       subject     'New Account Information'
#     end
#   end
#
# Postage::Mailer introduces a few mailer methods specific to Postage:
#
# * template  - template name that is defined in your PostageApp project
# * variables - extra variables you want to send along with the message
#
# Sending email
#
#   Notifier.deliver_signup_notification(user) # attempts to deliver to PostageApp (depending on env)
#   request = Notifier.create_signup_notification(user) # creates PostageApp::Request object
#
class PostageApp::Mailer < ActionMailer::Base
  # Using :test as a delivery method if set somewhere else
  unless (self.delivery_method == :test)
    self.delivery_method = :postage
  end
  
  adv_attr_accessor :postageapp_uid
  adv_attr_accessor :postageapp_api_key
  adv_attr_accessor :postageapp_template
  adv_attr_accessor :postageapp_variables
  
  def perform_delivery_postage(mail)
    mail.send
  end
  
  def deliver!(mail = @mail)
    unless (mail)
      raise 'PostageApp::Request object not present, cannot deliver'
    end

    if (perform_deliveries)
      __send__("perform_delivery_#{delivery_method}", mail)
    end
  end
  
  # Creating a Postage::Request object unlike TMail one in ActionMailer::Base
  def create_mail
    params = { }

    unless (self.recipients.blank?)
      params['recipients'] = self.recipients
    end
    
    params['headers'] = { }

    unless (self.subject.blank?)
      params['headers']['subject'] = self.subject
    end

    unless (self.subject.blank?)
      params['headers']['from'] = self.from
    end

    unless (self.headers.blank?)
      params['headers'].merge!(self.headers)
    end
    
    params['content'] = { }
    params['attachments'] = { }
    
    if (@parts.empty?)
      unless (self.body.blank?)
        params['content'][self.content_type] = self.body
      end
    else
      self.parts.each do |part|
        case (part.content_disposition)
        when 'inline'
          if (part.content_type.blank? && String === part.body)
            part.content_type = 'text/plain'
          end

          params['content'][part.content_type] = part.body
        when 'attachment'
          params['attachments'][part.filename] = {
            'content_type' => part.content_type,
            'content' => Base64.encode64(part.body)
          }
        end
      end
    end
    
    unless (self.postageapp_template.blank?)
      params['template']  = self.postageapp_template
    end

    unless (self.postageapp_variables.blank?)
      params['variables'] = self.postageapp_variables
    end
    
    if (params['headers'].blank?)
      params.delete('headers')
    end

    if (params['content'].blank?)
      params.delete('content')
    end

    if (params['attachments'].blank?)
      params.delete('attachments')
    end
    
    @mail = PostageApp::Request.new('send_message', params)

    unless (self.postageapp_uid.blank?)
      @mail.uid = self.postageapp_uid
    end

    unless (self.postageapp_api_key.blank?)
      @mail.api_key = self.postageapp_api_key
    end

    @mail
  end
  
  # Not insisting rendering a view if it's not there. PostageApp gem can send blank content
  # provided that the template is defined.
  def render(opts)
    super(opts)

  rescue ActionView::MissingTemplate
    # do nothing
  end
end
