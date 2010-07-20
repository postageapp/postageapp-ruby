class Hash
  
  # Example usage:
  #   @hash.dig(:k1)          # same as @hash[:k1]
  #   @hash.dig(:k1, :k2)     # same as @hash[:k1] && @hash[:k1][:k2]
  #   @hash.dig(:k1, :k2, k3) # same as @hash[:k1] && @hash[:k1][:k2] && @hash[:k1][:k2][:k3]
  def dig(*path)
    path.inject(self) do |location, key|
      location.respond_to?(:keys) ? location[key] : nil
    end
  end
  
  # Destructively convert all keys to strings.
  def stringify_keys!
    keys.each do |key|
      self[key.to_s] = delete(key)
    end
    self
  end
end

class Net::HTTP
  # Getting rid of the 'warning: peer certificate won't be verified in this SSL session'
  alias_method :old_initialize, :initialize
  def initialize(*args)
    old_initialize(*args)
    @ssl_context = OpenSSL::SSL::SSLContext.new
    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end