require 'fileutils'
require 'openssl'
require 'zlib'

StoreDir = 'store'
Subdirs = {
 file: 'files',
 chunk: 'chunks',
 tree: 'tree',
 root: 'root'
}

LockFile = 'lock'

class FileIOService
  def initialize
    @encrypter = nil
    @zipper = nil
  end

  def dirname(type, sha1)
    File.join( StoreDir, Subdirs[type], sha1[0...2] )
  end

  def filename(type, sha1)
    File.join( dirname( type, sha1 ), sha1[2..-1] )
  end

  def exists?(type, sha)
    File.exists? filename( type, sha )
  end

  def dir_list(dirname)
    Dir.foreach(dirname).sort.each{|f| yield f if f != '.' and f != '..'}
  end

  def get_stats(dirname, filename)
    path = File.join(dirname, filename)
    s = File.stat(path)
    { 
      :directory? => s.directory?,
      :mode => s.mode.to_s(8)[-3..-1],
      :filename => filename,
    }
  end

  def dir_list_with_stats(dirname)
    dir_list(dirname) { |filename| yield get_stats(dirname, filename) }
  end

  def dir_with_stats(dirname)
    DirWithStats.new(self, dirname)
  end

 def lock_file
    File.join( StoreDir, LockFile )
  end

  def create_lock
    if not Dir.exists? StoreDir 
      FileUtils.mkdir_p StoreDir
    end
    f = File.open(lock_file, 'w')
    f.close()
  end

  def create_elem(type, digest, &block)
    dir = dirname(type, digest)
    #print 'create_elem', digest, 'in', dir
    if not Dir.exists? dir 
      FileUtils.mkdir_p dir
    end
    File.open( filename(type, digest), 'w', &block ) 
  end

  def setup_encryption(key, iv)
    @encrypter = Encrypter.new(key, iv)
  end

  def setup_zip
    @zipper = Zipper.new
  end

  def read_elem(type, digest)
    File.open( filename(type, digest), 'r' ) do |file|
      content = file.read
      content = @encrypter.decrypt( content ) if @encrypter
      content = @zipper.unzip( content ) if @zipper
      yield content
    end
  end

  def write_elem(type, digest, content)
    content = @zipper.zip( content ) if @zipper
    content = @encrypter.encrypt( content ) if @encrypter
    create_elem(type, digest) {|f| f.write(content)}
  end

  def declare_root(digest)
    create_elem(:root, digest) {}
  end

  def list_elem(type)
    basedir = File.join( StoreDir, Subdirs[type] )
    dir_list( basedir ) do | subdir |
      dir_list( File.join(basedir, subdir) ) {|file| yield subdir+file}
    end
  end

  def lock
    raise if File.exists? lock_file
    create_lock
    yield
    File.delete lock_file
  end
end

class Zipper
  def zip(content)
    Zlib::Deflate.deflate( content )
  end

  def unzip(content)
    Zlib::Inflate.inflate( content )
  end
end

class Encrypter
  def initialize(key, iv)
    @cipher = OpenSSL::Cipher::AES.new(128, :CBC)
    @cipher.encrypt
    @cipher.key = key
    @cipher.iv = iv

    @decipher = OpenSSL::Cipher::AES.new(128, :CBC)
    @decipher.decrypt
    @decipher.key = key
    @decipher.iv = iv
  end

  def encrypt(content)
    @cipher.update( content ) + @cipher.final
  end

  def decrypt(content)
    @decipher.update( content ) + @decipher.final 
  end
end


class DirWithStats
  def initialize(ioservice, dirname)
    @io = ioservice
    @dirname = dirname
  end

  def each(&block)
    @io.dir_list_with_stats( @dirname, &block )
  end
end

