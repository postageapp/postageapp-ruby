require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'postageapp'

begin
  require 'redgreen' unless ENV['TM_FILEPATH'];
rescue LoadError; end 

class Test::Unit::TestCase
  
end
