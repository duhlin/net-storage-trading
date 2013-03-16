require_relative 'adler32'
require 'test/unit'

class TestAdler32 < Test::Unit::TestCase
  def test_wikipedia
    adler = Adler32.new 0 #0 for unlimited size
    adler << 'Wikipedia'
    assert_equal( '11e60398', adler.digest.to_s(16) )
  end

  def test_size
    adler = Adler32.new('Wikipedia'.size)
    adler << 'Wikipedia' 
    adler << 'Wikipedia'
    assert_equal( '11e60398', adler.digest.to_s(16) )
  end
end


