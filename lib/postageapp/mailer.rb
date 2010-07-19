require 'action_mailer'
require 'action_mailer/version'

# Loading PostageApp::Mailer class depending on what action_mailer is
# currently installed on the system. Assuming we're dealing only with
# ones that come with Rails 2 and 3
if ActionMailer::VERSION::MAJOR >= 3
  require File.expand_path('../mailer/mailer_3', __FILE__)
else
  require File.expand_path('../mailer/mailer_2', __FILE__)
end

# General helper methods for Request object to act more like TMail::Mail
# of Mail for testing
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