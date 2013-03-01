require_relative 'adler32'
require 'test/unit'

class TestAdler32 < Test::Unit::TestCase
  def test_wikipedia
    adler = Adler32.new
    adler << 'Wikipedia'
    assert_equal( '11e60398', adler.hexdigest )
  end

  def test_size
    adler = Adler32.new('Wikipedia'.size)
    adler << 'Wikipedia' 
    adler << 'Wikipedia'
    assert_equal( '11e60398', adler.hexdigest )
  end
end


