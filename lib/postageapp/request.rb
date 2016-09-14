class PostageApp::Request
  # == Constants ============================================================

  API_VERSION = '1.0'
  
  HEADERS_DEFAULT = {
    'Content-type' => 'application/json',
    'Accept' => 'text/json, application/json'
  }

  TimeoutError = defined?(::Timeout) ? ::Timeout::Error : ::TimeoutError

  # == Properties ===========================================================
  
  # Unique ID (UID) for the request
  attr_writer :uid
  
  # The API method being called (example: send_message)
  # This controls the url of the request (example: https://api.postageapp.com/v.1.0/send_message.json)
  attr_accessor :method

  # A list of arguments in a Hash format passed along with the request
  attr_accessor :arguments
  
  # Assigns the API key to be used for the request
  attr_accessor :api_key

  # == Class Methods ========================================================

  # Returns a user-agent string used for identification when making API calls.
  def self.user_agent
    @user_agent ||=
      "PostageApp (Gem %s, Ruby %s, %s)" % [
        PostageApp::VERSION,
        RUBY_VERSION,
        PostageApp.configuration.framework
      ]
  end

  # == Instance Methods =====================================================
  
  # Creates a new Request with the given API call method and arguments.
  def initialize(method, arguments = nil)
    @method = method
    @arguments = arguments ? arguments.dup : { }

    @uid = @arguments.delete('uid')
    @api_key = @arguments.delete('api_key') || PostageApp.configuration.api_key
  end
  
  # Skipping resend doesn't trigger PostageApp::FailedRequest.resend_all
  # it's needed so the request being resend doesn't create duplicate queue
  def send(skip_failed_requests_processing = false)
    http = PostageApp.configuration.http

    PostageApp.logger.info(self)
    
    http_response =
      begin
        http.post(
          url.path, 
          self.arguments_to_send.to_json, 
          HEADERS_DEFAULT.merge(
            'User-Agent' => self.class.user_agent
          )
        )

      rescue TimeoutError, Errno::ECONNREFUSED => e
        e
      end
    
    response = PostageApp::Response.new(http_response)
    
    PostageApp.logger.info(response)
    
    unless (skip_failed_requests_processing)
      if (response.fail?)
        PostageApp::FailedRequest.store(self)
      elsif (response.ok?)
        PostageApp::FailedRequest.resend_all
      end
    end
    
    response
  end

  # URL of the where PostageApp::Request will be directed at
  def url
    URI.parse("#{PostageApp.configuration.url}/v.#{API_VERSION}/#{self.method}.json")
  end
  
  # Unique ID of the request
  def uid(reload = false)
    @uid = nil if (reload)

    @uid ||= Digest::SHA1.hexdigest("#{rand}#{Time.now.to_f}#{self.arguments}")
  end
  
  # Returns the arguments that will be used to send this request.
  def arguments_to_send
    hash = {
      'uid' => self.uid,
      'api_key' => self.api_key
    }

    if (self.arguments && !self.arguments.empty?)
      case (self.method.to_sym)
      when :send_message
        if (PostageApp.configuration.recipient_override)
          self.arguments.merge!(
            'recipient_override' => PostageApp.configuration.recipient_override
          )
        end
      end

      hash.merge!(
        'arguments' => self.arguments.recursive_stringify_keys!
      )
    end
    
    hash
  end

  def content
    self.arguments['content'] ||= { }
  end

  # -- Mail::Message Emulation ----------------------------------------------

  def html_part
    self.content['text/html']
  end
  
  def text_part
    self.content['text/plain']
  end

  def find_first_mime_type(type)
    self.content[type]
  end

  def mime_type
    self.content.keys.first
  end

  def header
    self.arguments['headers'] ||= { }
  end

  def reply_to
    self.header['reply-to']
  end

  def cc
    self.header['cc']
  end

  def attachments
    self.arguments['attachments']
  end

  def multipart?
    self.content.keys.length > 1
  end

  # Getter and setter for headers. You can specify headers in the following
  # formats:
  #   headers['Custom-Header'] = 'Custom Value'
  #   headers 'Custom-Header-1' => 'Custom Value 1',
  #           'Custom-Header-2' => 'Custom Value 2'
  def headers(value = nil)
    _headers = self.arguments['headers'] ||= { }

    case (value)
    when Hash
      value.each do |k, v|
        _headers[k.to_s] = v.to_s
      end
    end

    _headers
  end

  def [](key)
    case (key)
    when :to, 'to'
      self.to
    when :from, 'from'
      self.from
    when :bcc, 'bcc'
      # Not supported via API at this time
      [ ]
    end
  end

  def to
    out = self.arguments_to_send.dig('arguments', 'recipients')

    case (out)
    when Hash
      out
    else
      [ out ].flatten
    end
  end

  def to=(list)
    self.arguments['recipients'] = list
  end

  def from
    [ self.arguments_to_send.dig('arguments', 'headers', 'from') ].flatten
  end

  def from=(address)
    _headers = self.arguments['headers'] ||= { }

    _headers['from'] = address.to_s
  end

  def bcc
    # Not supported natively via API at this time
    [ ]
  end

  def bcc=(list)
    # Not supported natively via API at this time
  end

  def subject
    self.arguments_to_send.dig('arguments', 'headers', 'subject')
  end

  def subject=(subject)
    _headers = self.arguments['headers'] ||= { }

    _headers['subject'] = subject.to_s
  end

  # # Emulation of Mail::Message interface
  # def body
  #   _content = self.arguments && self.arguments['content']

  #   _content and (_content['text/html'] or _content['text/plain'])
  # end

  def body
    out = self.arguments_to_send.dig('arguments', 'content')
    out.is_a?(Hash) ? out.values.join("\n\n") : out.to_s
  end
end
