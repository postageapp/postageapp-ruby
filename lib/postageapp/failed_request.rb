module PostageApp::FailedRequest
  
  # Stores request object into a file for future re-send
  # returns true if stored, false if not (due to undefined project path)
  def self.store(request)
    return false if !store_path || !PostageApp.configuration.requests_to_resend.member?(request.method.to_s)
    
    open(file_path(request.uid), 'w') do |f|
      f.write(Marshal.dump(request))
    end unless File.exists?(file_path(request.uid))
    
    PostageApp.logger.info "STORING FAILED REQUEST [#{request.uid}]"
    
    true
  end
  
  # Attempting to resend failed requests
  def self.resend_all
    return false if !store_path
    
    Dir.foreach(store_path) do |filename|
      next if !filename.match /^\w{40}$/
      
      request = initialize_request(filename)
      
      receipt_response = PostageApp::Request.new(:get_message_receipt, :uid => filename).send(true)
      if receipt_response.ok?
        PostageApp.logger.info "NOT RESENDING FAILED REQUEST [#{filename}]"
        File.delete(file_path(filename)) rescue nil
        
      elsif receipt_response.not_found?
        PostageApp.logger.info "RESENDING FAILED REQUEST [#{filename}]"
        response = request.send(true)
        
        # Not a fail, so we can remove this file, if it was then
        # there will be another attempt to resend
        File.delete(file_path(filename)) rescue nil if !response.fail?
      end
    end
    
    return
  end
  
  # Initializing PostageApp::Request object from the file
  def self.initialize_request(uid)
    return false if !store_path
    
    Marshal.load(File.read(file_path(uid))) if File.exists?(file_path(uid))
  end
  
protected
  
  def self.store_path
    return if !PostageApp.configuration.project_root
    dir = File.join(File.expand_path(PostageApp.configuration.project_root), 'tmp/postageapp_failed_requests')
    FileUtils.mkdir_p(dir) unless File.exists?(dir)
    return dir
  end
  
  def self.file_path(uid)
    File.join(store_path, uid)
  end
  
end