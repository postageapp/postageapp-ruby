module PostageApp::FailedRequest
  # == Module Methods =======================================================
  
  # Stores request object into a file for future re-send
  # returns true if stored, false if not (due to undefined project path)
  def self.store(request)
    return false unless (self.store_path) 
    return false unless (PostageApp.configuration.requests_to_resend.member?(request.method.to_s))
    
    path = file_path(request.uid)
    unless (File.exist?(path))
      open(path, 'wb') do |f|
        f.write(Marshal.dump(request))
      rescue StandardError => e
        self.force_delete!(path)
        raise e
      end
    end
    
    PostageApp.logger.info("STORING FAILED REQUEST [#{request.uid}]")
    
    true
  end

  def self.force_delete!(path)
    File.delete(path)

  rescue
    nil
  end
  
  # Attempting to resend failed requests
  def self.resend_all
    return false unless (self.store_path)
    
    Dir.foreach(store_path) do |filename|
      next unless (filename.match(/^\w{40}$/))
      
      request = initialize_request(filename)
      next unless request
      
      receipt_response = PostageApp::Request.new(
        :get_message_receipt,
        uid: filename
      ).send(true)

      if (receipt_response.not_found?)
        PostageApp.logger.info("Retrying failed request [#{filename}]")

        response = request.send(true)
        
        PostageApp.logger.info(response)

        # Not a fail, so we can remove this file, if it was then
        # there will be another attempt to resend

        unless (response.retryable?)
          force_delete!(file_path(filename))
        end
      elsif (receipt_response.ok?)
        PostageApp.logger.info("Skipping failed request (already sent) [#{filename}]")

        force_delete!(file_path(filename))
      end
    end

    return
  end
  
  # Initializing PostageApp::Request object from the file
  def self.initialize_request(uid)
    return false unless (self.store_path)
    return false unless (File.exist?(file_path(uid)))

    request = Marshal.load(File.read(file_path(uid)))
    raise "Marshaled file is not PostageApp::Request" unless request.is_a?(PostageApp::Request)

    return request

  rescue StandardError => e
    PostageApp.logger.warn("Skipping failed request [#{uid}]: #{e}")

    force_delete!(file_path(uid))

    false
  end
  
protected
  def self.store_path
    return unless (PostageApp.configuration.project_root)

    dir = File.join(
      File.expand_path(PostageApp.configuration.project_root),
      'tmp/postageapp_failed_requests'
    )
    
    unless (File.exist?(dir))
      FileUtils.mkdir_p(dir)
    end
    
    dir
  end
  
  def self.file_path(uid)
    File.join(store_path, uid)
  end
end
