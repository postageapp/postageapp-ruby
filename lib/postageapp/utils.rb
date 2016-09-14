class Hash
  # Ruby 2.3.0 adds the dig method so this needs to be conditional.
  unless ((instance_methods & [ :dig ]).any?)
    # Example usage:
    #   @hash.dig(:k1)          # same as @hash[:k1]
    #   @hash.dig(:k1, :k2)     # same as @hash[:k1] && @hash[:k1][:k2]
    #   @hash.dig(:k1, :k2, k3) # same as @hash[:k1] && @hash[:k1][:k2] && @hash[:k1][:k2][:k3]
    def dig(*path)
      path.inject(self) do |location, key|
        location.respond_to?(:keys) ? location[key] : nil
      end
    end
  end
  
  unless ((instance_methods & [ :recursive_stringify_keys! ]).any?)
    # Destructively convert all keys to strings.
    def recursive_stringify_keys!
      keys.each do |key|
        value = delete(key)

        self[key.to_s] =
          case (value)
          when Hash
            value.recursive_stringify_keys!
          else
            value
          end
      end

      self
    end
  end
end
