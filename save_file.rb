require 'openssl'

ChunkSize=50
StoreDir = 'store'

def chunk_dirname(sha1)
  StoreDir + '/' + sha1[0...2]
end

def chunk_filename(sha1)
  chunk_dirname( sha1 ) + '/' + sha1[2..-1]
end

def write_elem(digest, content)
  if not Dir.exists? chunk_dirname(digest) 
    Dir.mkdir( chunk_dirname(digest) )
  end
  File.open( chunk_filename(digest), 'w' ) do |file|
    file.write(content)
  end
end

def write_chunk( content )
  sha1 = Digest::SHA1.new
  digest = sha1.hexdigest( content )
  write_elem( digest, content )
  digest
end

def write_file(file)
  buffer = ''
  last_index = 0

  content = []
  file_sha1 = Digest::SHA1.new
  rolling_sha1 = Digest::SHA1.new
  file.each_byte do |byte|
    buffer << byte
    head = buffer[0...-ChunkSize]
    tail = buffer[-ChunkSize..-1] || buffer
    tail_digest = rolling_sha1.hexdigest( tail )
    if File.exists? chunk_filename( tail_digest )
      if not head.empty?
        file_sha1 << head
        content.push( write_chunk( head ) )
      end
      file_sha1 << tail
      content.push( tail_digest )
      buffer = ''
    elsif head.size == ChunkSize
      file_sha1 << head
      content.push( write_chunk( head ) )
      buffer = tail
    end
  end
  if not buffer.empty?
    file_sha1 << buffer
    content.push( write_chunk( buffer ) )
  end
  write_elem( file_sha1.hexdigest, content.join("\n")+"\n" )
  file_sha1.hexdigest
end

puts write_file(ARGF)
