require 'action_mailer'
require 'action_mailer/version'

# Loading PostageApp::Mailer class depending on what action_mailer is
# currently installed on the system. Assuming we're dealing only with
# ones that come with Rails 2 and 3
if ActionMailer::VERSION::MAJOR >= 3
  require File.expand_path('../action_mailer_3/mailer', __FILE__)
  require File.expand_path('../action_mailer_3/request', __FILE__)
else
  require File.expand_path('../action_mailer_2/mailer', __FILE__)
  require File.expand_path('../action_mailer_2/request', __FILE__)
end