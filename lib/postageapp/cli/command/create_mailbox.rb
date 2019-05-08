PostageApp::CLI::Command.define(:create_mailbox) do
  api_key :account

  argument :uid,
    optional: true,
    description: 'An identifier to refer to this mailbox on subsequent API calls'
  argument :label,
    optional: true,
    description: 'A descriptive name for this mailbox'
  argument :host,
    description: 'IMAP server hostname'
  argument :port,
    optional: true,
    description: 'IMAP server port (default 993)'
  argument :username,
    description: 'Username/email-address used to authenticate with the IMAP server'
  argument :password,
    description: 'Password used to authenticate with the IMAP server'
  argument :postback_url,
    description: 'The URL to post received email content to'
end
