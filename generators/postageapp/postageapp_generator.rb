# Wrapper around rake manifest
Rails::Generator::Commands::Create.class_eval do
  def rake(command)
    system "rake #{command}"
  end
end

# Rails 2 Generator
class PostageappGenerator < Rails::Generator::Base
  
  def add_options!(opt)
    opt.on('-k=key', '--api-key=key') do |value|
      options[:api_key] = value
    end
  end
  
  def manifest
    if !options[:api_key]
      puts 'Must pass --api-key with API key of your PostageApp.com project'
      exit
    end
    
    record do |m|
      m.template 'initializer.rb', 'config/initializers/postageapp.rb', 
        :assigns    => { :api_key => options[:api_key] },
        :collision  => :force
      m.directory 'lib/tasks'
      m.file 'postageapp_tasks.rake', 'lib/tasks/postageapp_tasks.rake',
        :collision  => :force
      m.rake 'postageapp:test'
    end
  end
  
end