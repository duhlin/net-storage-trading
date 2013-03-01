require 'openssl'
require 'set'
require_relative 'ioservice'
require_relative 'adler32'
require_relative 'adler_storage'

ChunkSize=1024*256

class SplitAndWriteChunks
  def initialize(ioservice)
    #@file_sha1 = Digest::SHA1.new
    #@content = []
    @io = ioservice
    @adlers = AdlerDB::load
  end

  def save_file(file)
    @content = []
    @file_sha1 = Digest::SHA1.new
    buffer = ''
    rolling_adler = Adler32.new(ChunkSize)
    tail_sha = Digest::SHA1.new

    #iterate over file content
    file.each_byte do |byte|
      buffer << byte
      head = buffer[0...-ChunkSize]
      tail = buffer[-ChunkSize..-1] || buffer
      rolling_adler << byte
      tail_adler_digest = rolling_adler.hexdigest
      tail_sha_candidates = @adlers[ tail_adler_digest ]
      #is there is already a chunk with the same adler?
      if tail_sha_candidates
        puts tail_sha_candidates
        #there is one, compare sha then
        tail_sha_digest = tail_sha.hexdigest tail
        if tail_sha_candidates.member? tail_sha_digest
          #sha find too! do not create a new one
          #sha has been found, there should be a chunk with this name
          fail if not @io.exists? :chunk, tail_sha_digest
          if not head.empty?
            handle_chunk( head )
          end
          handle_chunk( tail )
          buffer = ''
          rolling_adler = Adler32.new(ChunkSize)
        end
      elsif head.size == ChunkSize
        handle_chunk( head )
        buffer = tail
      end
    end
    if not buffer.empty?
      handle_chunk( buffer )
    end
    handle_file
    AdlerDB::save @adlers
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

    adler = Adler32.new( ChunkSize )
    adler << content
    adler_digest = adler.hexdigest
    if @adlers.key? adler_digest
      @adlers[ adler_digest ] << digest
    else
      @adlers[ adler_digest ] = Set.new( [ digest ] )
    end
  end
end

s = SplitAndWriteChunks.new( FileIOService.new )
puts s.save_file( ARGF ) 

