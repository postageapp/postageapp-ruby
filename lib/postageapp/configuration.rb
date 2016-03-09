# PostageApp::Configuration is used to retrieve and manipulate the options
# used to connect to the API. There are a number of options which can be set.
# The recommended method for doing this is via the initializer file that's
# generated upon installation: config/initializers/postageapp.rb

# Basic Options
# -------------
# :api_key - The API key used to send requests, can also be set via the
#            POSTAGEAPP_API_KEY environment variable. (required)
# :secure - true for HTTPS, false for HTTP connections (default: true)
# :recipient_override - Email address to send all email to regardless of
#                       specified recipients. Used for testing.

# Non-Rails Options
# -----------------
# :project_root - The base path of the project, used to determine where to
#                 save log files and failed API calls.
# :framework - A string identifier for the framework being used. Shows up in
#              the User-Agent identifier of requests.
# :environment - The operational mode of the application, typically either
#                'production' or 'development' but any string value is allowed.
#                (default: 'production')
# :logger - Used to assign a specific logger.

# Network Options
# ---------------
# :host - The API host to connect to (default: 'api.postageapp.com')
# :http_open_timeout - HTTP open timeout in seconds (default: 2)
# :http_read_timeout - Read timeout in seconds (default: 5)

# Proxy Options
# -------------
# :proxy_host - Proxy server hostname
# :proxy_port - Proxy server port
# :proxy_user - Proxy server username
# :proxy_pass - Proxy server password

# Advanced Options
# ----------------
# :port - The port to make HTTP/HTTPS requests (default based on secure option)
# :protocol - Set to either `http` or `https` (default based on secure option)
# :requests_to_resend - List of API calls that should be replayed if they fail.
#                       (default: send_message)

class PostageApp::Configuration
  attr_accessor :secure
  attr_writer :protocol
  attr_accessor :host
  attr_writer :port
  attr_accessor :proxy_host
  attr_accessor :proxy_port
  attr_accessor :proxy_user
  attr_accessor :proxy_pass
  attr_accessor :http_open_timeout
  attr_accessor :http_read_timeout
  attr_accessor :recipient_override
  attr_accessor :requests_to_resend
  attr_accessor :project_root
  attr_accessor :framework
  attr_accessor :environment
  attr_accessor :logger
  
  def initialize
    @secure = true
    @host = 'api.postageapp.com'

    @http_open_timeout = 5
    @http_read_timeout = 10

    @requests_to_resend = %w[ send_message ]

    @framework = 'Ruby'

    @environment = 'production'
  end
  
  alias_method :secure?, :secure
  
  # Assign which API key is used to make API calls. Can also be specified
  # using the `POSTAGEAPP_API_KEY` environment variable.
  def api_key=(key)
    @api_key = key
  end
  
  # Returns the API key used to make API calls. Can be specified as the
  # `POSTAGEAPP_API_KEY` environment variable.
  def api_key
    @api_key ||= ENV['POSTAGEAPP_API_KEY']
  end
  
  # Returns the HTTP protocol used to make API calls
  def protocol
    @protocol ||= (secure? ? 'https' : 'http')
  end
  
  # Returns the port used to make API calls
  def port
    @port ||= (secure? ? 443 : 80)
  end
  
  # Returns the endpoint URL to make API calls
  def url
    "#{self.protocol}://#{self.host}:#{self.port}"
  end

  # Returns a properly configured Net::HTTP connection
  def http
    http = Net::HTTP::Proxy(
      self.proxy_host,
      self.proxy_port,
      self.proxy_user,
      self.proxy_pass
    ).new(self.host, self.port)
    
    http.read_timeout = self.http_read_timeout
    http.open_timeout = self.http_open_timeout
    http.use_ssl = self.secure?

    http
  end
end
