class PostageAppGenerator < Rails::Generator::Base
  
  def add_options!(opt)
    opt.on('-k', '--api_key') do |value|
      options[:api_key] = value
    end
  end
  
  def manifest
    if !options[:api_key]
      puts 'Must pass --api_key with API key of your PostageApp.com project'
      exit
    end
    
    record do |m|
      m.template 'initializer.rb', 'config/initializers/postageapp.rb', :assigns => {
        :api_key => options[:api_key]
      }
    end
    
  end
  
end