require 'minitest/autorun'
require 'shoulda/context'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'solver'

class MiniTest::Unit::TestCase
end
