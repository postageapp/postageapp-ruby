begin
  require 'active_support'
  require 'action_mailer'
  require 'action_mailer/version'

rescue LoadError
  # ActionMailer not available
end

if (defined?(ActionMailer))
  require_relative './mailer/mailer_4'
end
