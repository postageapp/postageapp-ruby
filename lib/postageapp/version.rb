module PostageApp
  VERSION = begin 
    IO.read(File.join(File.dirname(__FILE__), '/../../VERSION'))
  rescue
    'UNKNOWN'
  end
end