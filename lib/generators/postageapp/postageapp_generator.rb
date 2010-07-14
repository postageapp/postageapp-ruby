require 'rails/generators'

class PostageappGenerator < Rails::Generators::Base
  
  class_option :api_key, :aliases => ['-k=value', '--api-key=value'], :type => :string, :desc => 'Your PostageApp API key'
  
  def self.source_root
    @_hoptoad_source_root ||= File.expand_path("../../../../../generators/postageapp/templates", __FILE__)
  end
  
  def install
    template 'initializer.rb', 'config/initializers/postageapp.rb'
  end
  
end