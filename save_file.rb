require 'openssl'
require_relative 'ioservice'

ChunkSize=50

class SplitAndWriteChunks
  def initialize(ioservice)
    #@file_sha1 = Digest::SHA1.new
    #@content = []
    @io = ioservice
  end

  def save_file(file)
    @content = []
    @file_sha1 = Digest::SHA1.new
    buffer = ''
    rolling_sha1 = Digest::SHA1.new

    #iterate over file content
    file.each_byte do |byte|
      buffer << byte
      head = buffer[0...-ChunkSize]
      tail = buffer[-ChunkSize..-1] || buffer
      tail_digest = rolling_sha1.hexdigest( tail )
      if @io.exists? :chunk, tail_digest
        if not head.empty?
          handle_chunk( head )
        end
        handle_chunk( tail )
        buffer = ''
      elsif head.size == ChunkSize
        handle_chunk( head )
        buffer = tail
      end
    end
    if not buffer.empty?
      handle_chunk( buffer )
    end
    handle_file
    @file_sha1.hexdigest
  end
private
  def handle_file
    @io.write_elem( :file, @file_sha1.hexdigest, @content.join("\n")+"\n" )
  end

  def handle_chunk( content )
    @file_sha1 << content
    sha1 = Digest::SHA1.new
    digest = sha1.hexdigest( content )
    @content.push( digest )
    @io.write_elem( :chunk, digest, content )
  end
end

s = SplitAndWriteChunks.new( FileIOService.new )
puts s.save_file( ARGF ) 

