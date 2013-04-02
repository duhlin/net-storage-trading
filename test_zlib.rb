require 'zlib'
require 'test/unit'

class Test_encryption < Test::Unit::TestCase
  def setup
    @plain_text = "I don't really have anything to say.\nBut I want it to be kept secure\n"
    @deflate = Zlib::Deflate.new
    @inflate = Zlib::Inflate.new
  end

  def test_zip
    zip_text = @deflate.deflate( @plain_text ) + @deflate.finish
    unzip_text = @inflate.inflate( zip_text ) + @inflate.finish
    assert_equal(@plain_text, unzip_text)
  end

  def test_zip_with_several_calls
    zip_text = ''
    @plain_text.each_line do |line|
      zip_text << @deflate.deflate( line )
    end
    zip_text << @deflate.finish
    
    unzip_text = @inflate.inflate( zip_text ) + @inflate.finish
    assert_equal(@plain_text, unzip_text)
  end
 
  def test_unzip_with_several_calls
    zip_text = @deflate.deflate( @plain_text ) + @deflate.finish
    unzip_text = ''
    zip_text.each_char.each_slice(3) do |buf|
      unzip_text << @inflate.inflate( buf.join )
    end
    unzip_text << @inflate.finish
    assert_equal(@plain_text, unzip_text)
  end
end

