require 'fileutils'

StoreDir = 'store'
Subdirs = {
 file: 'files',
 chunk: 'chunks'
}

class FileIOService
  def dirname(type, sha1)
    File.join( StoreDir, Subdirs[type], sha1[0...2] )
  end

  def filename(type, sha1)
    File.join( dirname( type, sha1 ), sha1[2..-1] )
  end

  def exists?(type, sha)
    File.exists? filename( type, sha )
  end

  def read_elem(type, digest, &block)
    File.open( filename(type, digest), 'r' ) do |file|
      yield file
    end
  end

  def write_elem(type, digest, content)
    dir = dirname(type, digest)
    #print 'write_elem', digest, 'in', dir
    if not Dir.exists? dir 
      FileUtils.mkdir_p dir
    end
    File.open( filename(type, digest), 'w' ) do |file|
      file.write(content)
    end
  end
end



