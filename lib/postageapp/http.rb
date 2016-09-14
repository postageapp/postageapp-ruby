module PostageApp::HTTP
  # == Moduule Methods ======================================================

  def self.connect(config)
    connector =
      if (config.proxy?)
        Net::HTTP::Proxy(
          config.proxy_host,
          config.proxy_port || SOCKS5_PORT_DEFAULT,
          config.proxy_user,
          config.proxy_pass
        )
      else
        Net::HTTP
      end

    http = connector.new(config.host, config.port)

    unless (config.verify_certificate?)
      context = OpenSSL::SSL::SSLContext.new
      context.verify_mode = OpenSSL::SSL::VERIFY_NONE

      http.send(:instance_variable_set, :@ssl_context, context)
    end

    http.read_timeout = config.http_read_timeout
    http.open_timeout = config.http_open_timeout
    http.use_ssl = config.secure?

    http
  end
end
