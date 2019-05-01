module PostageApp::Env
  def self.rails?
    defined?(Rails)
  end

  def self.rails_with_encrypted_credentials?
    defined?(Rails) and Rails.respond_to?(:application) and Rails.application.respond_to?(:credentials)
  end
end
