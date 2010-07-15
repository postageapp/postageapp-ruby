PostageApp Gem
==============

This is the gem used to integrate Ruby apps with PostageApp service. 

Installation
------------

### Rails 3.*
Add postageapp gem to your Gemfile:
    
    gem 'postageapp'
    
Then from the Rails project's root run:
    
    bundle install
    script/rails generate postageapp --api-key POSTAGEAPP_PROJECT_API_KEY
  
### Rails 2.*
In config/environment.rb add the following:
    
    config.gem 'postageapp'
    
Then from the Rails project's root run:
    
    rake gems:install
    rake gems:unpack GEM=postageapp
    script/generate postageapp --api-key POSTAGEAPP_PROJECT_API_KEY

### Sinatra / Rack / Others
It's as simple as doing something like this:
    
    require 'postageapp'
    
    PostageApp.configure do |config|
      config.api_key = 'POSTAGEAPP_PROJECT_API_KEY'
    end

Usage
-----
Here's an example of sending a message. {See full API documentation}[http://TODO/] 
  
    request = PostageApp::Request.new(:send_message, {
      'headers'     => { 'from'     => 'sender@example.com',
                         'subject'  => 'Email Subject' },
      'recipients'  => 'recipient@example.com',
      'content'     => {
        'text/plain'  => 'text email content',
        'text/html'   => 'html email content'
      }
    })
    response = request.send
  
`PostageApp::Response` object allows you to check the status:
  
    >> response.status
    => 'ok'
  
Alternatively you may use:

    >> response.fail?
    => false
    >> response.ok?
    => true
  
Response comes back with data:
  
    >> response.data
    => { 'message' => { 'id' => '12345' }}

ActionMailer Integration
------------------------

TODO

Copyright
---------

(C) 2009 {The Working Group, Inc}[http://www.twg.ca/]
