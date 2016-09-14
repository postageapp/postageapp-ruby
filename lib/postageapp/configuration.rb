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
# :scheme - Set to either `http` or `https` (default based on secure option)
# :requests_to_resend - List of API calls that should be replayed if they fail.
#                       (default: send_message)

class PostageApp::Configuration
  # == Constants ============================================================

  HOST_DEFAULT = 'api.postageapp.com'.freeze

  SOCKS5_PORT_DEFAULT = 1080
  HTTP_PORT_DEFAULT = 80
  HTTPS_PORT_DEFAULT = 443

  SCHEME_FOR_SECURE = {
    true => 'https'.freeze,
    false => 'http'.freeze
  }.freeze

  PATH_DEFAULT = '/'.freeze

  FRAMEWORK_DEFAULT = 'Ruby'.freeze
  ENVIRONMENT_DEFAULT = 'production'.freeze

  # == Properties ===========================================================

  attr_accessor :secure
  attr_writer :scheme
  attr_accessor :host
  attr_writer :port
  attr_accessor :proxy_host
  attr_writer :proxy_port
  attr_accessor :proxy_user
  attr_accessor :proxy_pass

  attr_accessor :verify_certificate
  attr_accessor :http_open_timeout
  attr_accessor :http_read_timeout
  attr_accessor :recipient_override
  attr_accessor :requests_to_resend
  attr_accessor :project_root
  attr_accessor :framework
  attr_accessor :environment
  attr_accessor :logger

  # == Instance Methods =====================================================
  
  def initialize
    @secure = true
    @verify_certificate = true

    @host = ENV['POSTAGEAPP_HOST'] || HOST_DEFAULT

    @proxy_port = SOCKS5_PORT_DEFAULT

    @http_open_timeout = 5
    @http_read_timeout = 10

    @requests_to_resend = %w[ send_message ]

    @framework = FRAMEWORK_DEFAULT
    @environment = ENVIRONMENT_DEFAULT
  end
  
  alias_method :secure?, :secure
  alias_method :verify_certificate?, :verify_certificate

  def port_default?
    if (self.secure?)
      self.port == HTTPS_PORT_DEFAULT
    else
      self.port == HTTP_PORT_DEFAULT
    end
  end

  def proxy?
    self.proxy_host and self.proxy_host.match(/\A\S+\z/)
  end

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
  
  # Returns the HTTP scheme used to make API calls
  def scheme
    @scheme ||= SCHEME_FOR_SECURE[self.secure?]
  end

  alias_method :protocol=, :scheme=
  alias_method :protocol, :scheme
  
  # Returns the port used to make API calls
  def port
    @port ||= (self.secure? ? HTTPS_PORT_DEFAULT : HTTP_PORT_DEFAULT)
  end

  # Returns the port used to connect via SOCKS5
  def proxy_port
    @proxy_port ||= SOCKS5_PORT_DEFAULT
  end
  
  # Returns the endpoint URL to make API calls
  def url
    '%s://%s%s' % [
      self.scheme,
      self.host,
      self.port_default? ? '' : (':%d' % self.port)
    ]
  end

  # Returns a connection aimed at the API endpoint
  def http
    PostageApp::HTTP.connect(self)
  end
end
