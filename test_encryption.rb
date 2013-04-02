require 'openssl'
require 'test/unit'

class Test_encryption < Test::Unit::TestCase
  def setup
    @cipher = OpenSSL::Cipher::AES.new(128, :CBC)
    @cipher.encrypt
    @key = @cipher.random_key
    @iv = @cipher.random_iv

    @decipher = OpenSSL::Cipher::AES.new(128, :CBC)
    @decipher.decrypt
    @decipher.key = @key
    @decipher.iv = @iv
    
    @plain_text = "I don't really have anything to say.\nBut I want it to be kept secure\n"
  end

  def test_encrypt
    enc_text = @cipher.update(@plain_text) + @cipher.final
    dec_text = @decipher.update(enc_text) + @decipher.final
    assert_equal(@plain_text, dec_text)
  end

  def test_encrypt_with_several_calls
    enc_text = ''
    @plain_text.each_line do |line|
      enc_text << @cipher.update( line )
    end
    enc_text << @cipher.final
    
    dec_text = @decipher.update(enc_text) + @decipher.final
    assert_equal(@plain_text, dec_text)
  end
 
  def test_decrypt_with_several_calls
    enc_text = @cipher.update(@plain_text) + @cipher.final
    dec_text = ''
    enc_text.each_char.each_slice(3) do |buf|
      dec_text << @decipher.update( buf.join )
    end
    dec_text << @decipher.final
    assert_equal(@plain_text, dec_text)
  end
end

