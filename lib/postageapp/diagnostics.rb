require 'socket'

class PostageApp::Diagnostics
  # == Instance Methods =====================================================

  def initialize(config)
    @config = config
  end

  def proxy_host_resolved
    resolve(@config.proxy_host, 'socks5')
  end

  def host_resolved
    resolve(@config.host, @config.protocol)
  end

protected
  def resolve(fqdn, service)
    return unless (fqdn)

    Socket.getaddrinfo(fqdn, service).map do |e|
      # Result: [ family, port, name, ip, faily, socktype, protocol ]
      e[3]
    end.uniq

  rescue SocketError
    # Couldn't resolve, so nil
  end
end
