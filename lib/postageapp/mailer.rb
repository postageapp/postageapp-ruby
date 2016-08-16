begin
  require 'active_support'
  require 'action_mailer'
  require 'action_mailer/version'

rescue LoadError
  # ActionMailer not available
end

if (defined?(ActionMailer))
  # Loading PostageApp::Mailer class depending on what action_mailer is
  # currently installed on the system. Assuming we're dealing only with
  # ones that come with Rails 2 and 3
  case (ActionMailer::VERSION::MAJOR)
  when 3
    require File.expand_path('mailer/mailer_3', File.dirname(__FILE__))
  when 2
    require File.expand_path('mailer/mailer_2', File.dirname(__FILE__))
  else
    require File.expand_path('mailer/mailer_4', File.dirname(__FILE__))
  end
end
