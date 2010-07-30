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
  self.delivery_method = :postage unless (self.delivery_method == :test)
  
  adv_attr_accessor :postageapp_template
  adv_attr_accessor :postageapp_variables
  
  def perform_delivery_postage(mail)
    mail.send
  end
  
  def deliver!(mail = @mail)
    raise 'PostageApp::Request object not present, cannot deliver' unless mail
    __send__("perform_delivery_#{delivery_method}", mail) if perform_deliveries
  end
  
  # Creating a Postage::Request object unlike TMail one in ActionMailer::Base
  def create_mail
    params = { }
    params['recipients'] = self.recipients unless self.recipients.blank?
    
    params['headers'] = { }
    params['headers']['subject']  = self.subject  unless self.subject.blank?
    params['headers']['from']     = self.from     unless self.from.blank?
    params['headers'].merge!(self.headers)        unless self.headers.blank?
    
    params['content'] = { }
    params['attachments'] = { }
    
    if @parts.empty?
      params['content'][self.content_type] = self.body unless self.body.blank?
    else
      self.parts.each do |part|
        case part.content_disposition
        when 'inline'
          part.content_type = 'text/plain' if part.content_type.blank? && String === part.body
          params['content'][part.content_type] = part.body
        when 'attachment'
          params['attachments'][part.filename] = {
            'content_type' => part.content_type,
            'content'      => Base64.encode64(part.body)
          }
        end
      end
    end
    
    params['template'] = self.postageapp_template unless self.postageapp_template.blank?
    params['variables'] = self.postageapp_variables unless self.postageapp_variables.blank?
    
    params.delete('headers')     if params['headers'].blank?
    params.delete('content')     if params['content'].blank?
    params.delete('attachments') if params['attachments'].blank?
    
    @mail = PostageApp::Request.new(:send_message, params)
  end
  
  # Not insisting rendering a view if it's not there. PostageApp gem can send blank content
  # provided that the template is defined.
  def render(opts)
    super(opts)
  rescue ActionView::MissingTemplate
    # do nothing
  end
  
end