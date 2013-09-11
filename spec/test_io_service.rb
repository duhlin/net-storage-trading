require 'ioservice'
require 'test/unit'

def CheckWriteAndRead(io, id, content)
  io.write_elem(:chunk, id, content)
  io.read_elem(:chunk, id) { |r| assert_equal(r, content) }
end

def GenRandomKeyAndIv
  cipher = OpenSSL::Cipher::AES.new(128, :CBC)
  { key: cipher.random_key, iv: cipher.random_iv }
end

class Test_ioservice < Test::Unit::TestCase
  def setup
    @io = FileIOService.new
  end

  #an element saved with write_elem can be read with read_elem
  def test
    CheckWriteAndRead(@io, 'test_id', 'test content')
    CheckWriteAndRead(@io, 'test_id', 'test content a second time')
  end

  #ioservice uses Zlib to zip/unzip content.
  #even when zip is enabled, read should retrieve what was written
  def test_zip
    @io.setup_zip
    CheckWriteAndRead(@io, 'test_id', 'test content for zip')
    CheckWriteAndRead(@io, 'test_id', 'test content for zip a second time')
  end

  #ioservice can encrypt content
  #when encryption is enabled, read should retrieve what was written
  def test_encrypt
    #generate random keys and iv
    g = GenRandomKeyAndIv()

    @io.setup_encryption(g[:key], g[:iv])
    CheckWriteAndRead(@io, 'test_id', 'test content for encryption')
    CheckWriteAndRead(@io, 'test_id', 'test content for encryption a second time')
  end

  #encryption and zip can be used at the same time
  def test_encrypt_and_zip
    g = GenRandomKeyAndIv()
    @io.setup_encryption(g[:key], g[:iv])
    @io.setup_zip

    CheckWriteAndRead(@io, 'test_id', 'test content for zip and encryption')
    CheckWriteAndRead(@io, 'test_id', 'test content for zip and encryption a second time')
  end
end


