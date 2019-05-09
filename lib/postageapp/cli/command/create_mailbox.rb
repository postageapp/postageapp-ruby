PostageApp::CLI::Command.define do
  api_key :account

  argument :uid,
    optional: true,
    desc: 'An identifier to refer to this mailbox on subsequent API calls'
  argument :label,
    optional: true,
    desc: 'A descriptive name for this mailbox'
  argument :host,
    desc: 'IMAP server hostname'
  argument :port,
    optional: true,
    desc: 'IMAP server port (default 993)'
  argument :username,
    desc: 'Username/email-address used to authenticate with the IMAP server'
  argument :password,
    desc: 'Password used to authenticate with the IMAP server'
  argument :postback_url,
    desc: 'The URL to post received email content to'
end
