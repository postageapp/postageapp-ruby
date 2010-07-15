require 'action_mailer'
require 'action_mailer/version'

# Loading PostageApp::Mailer class depending on what action_mailer is
# currently installed on the system. Assuming we're dealing only with
# ones that come with Rails 2 and 3
if ActionMailer::VERSION::MAJOR >= 3
  require File.expand_path('../mailer/mailer_am3', __FILE__)
else
  require File.expand_path('../mailer/mailer_am2', __FILE__)
end

# A set of methods that are useful when request needs to behave as
# TMail::Mail or Mail object
class PostageApp::Request
  
  def to
    self.arguments_to_send.dig('arguments', 'recipients')
  end
  
  def from
    self.arguments_to_send.dig('arguments', 'headers', 'from')
  end
  
  def subject
    self.arguments_to_send.dig('arguments', 'headers', 'subject')
  end
  
  def body
    self.arguments_to_send.dig('arguments', 'content')
  end
  
end