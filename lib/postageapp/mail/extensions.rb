module PostageApp::Mail::Extensions
  def self.install!
    # Register PostageApp as a valid Mail delivery method, allows the shorthand
    # Mail.delivery_method :postageapp
    ::Mail::Configuration.class_eval do
      alias_method :__base_lookup_delivery_method, :lookup_delivery_method

      def lookup_delivery_method(method)
        case (method.is_a?(String) ? method.to_sym : method)
        when :postageapp
          PostageApp::Mail::DeliveryMethod
        else
          __base_lookup_delivery_method(method)
        end
      end
    end
  end
end
