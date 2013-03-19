require 'openssl'
require 'set'
require_relative 'ioservice'
require_relative 'C_adler32/adler32'
require_relative 'adler_storage'

class SplitAndWriteChunks
  attr_reader :io

  def initialize(ioservice, adlers, chunksize = 1024*256)
    @io = ioservice
    @adlers = adlers
    @ChunkSize= chunksize
  end

  def save_file(file)
    @content = []
    @file_sha1 = Digest::SHA1.new
    buffer = []
    rolling_adler = Adler32.new(@ChunkSize)
    rolling_adler_digest = ''
    buffer_sha = Digest::SHA1.new

    #iterate over file content
    file.each_byte do |byte|
      buffer.push byte
      rolling_adler.newByte( byte )
      rolling_adler_digest = rolling_adler.digest.to_s(16)
      buffer_sha_candidates = @adlers[ rolling_adler_digest ]
      #is there is already a chunk with the same adler?
      if buffer_sha_candidates
        #there is one, compare sha then
        buffer_sha_digest = buffer_sha.hexdigest buffer.last(@ChunkSize).pack('C*')
        if buffer_sha_candidates.member? buffer_sha_digest
          #sha find too! do not create a new one
          #sha has been found, there should be a chunk with this name
          fail if not @io.exists? :chunk, buffer_sha_digest
          #puts "recognized end of '#{buffer.pack('C*')}'"
          handle_chunk( buffer.shift(buffer.size-@ChunkSize), nil ) if buffer.size > @ChunkSize
          handle_chunk( buffer, rolling_adler_digest ) 
          buffer.clear
          rolling_adler = Adler32.new(@ChunkSize)
        end
      elsif buffer.size == 2*@ChunkSize
        handle_chunk( (buffer.shift @ChunkSize), nil ) #remove the first @ChunkSize bytes and create a chunk with it
      end
    end
    #insert remaining if any
    handle_chunk( buffer.shift(@ChunkSize), nil ) if not buffer.empty?
    handle_chunk( buffer, nil) if not buffer.empty? 
    handle_file
    @file_sha1.hexdigest
  end
private
  def handle_file
    #puts "handle_file, #{@file_sha1.hexdigest}"
    if not @io.exists? :file, @file_sha1.hexdigest
      @io.write_elem( :file, @file_sha1.hexdigest, @content.join("\n")+"\n" )
    end
  end

  def ComputeAdlerDigest(content)
    adler = Adler32.new(0)
    adler << content
    adler.digest.to_s(16)
  end

  def handle_chunk( content, adler_digest )
    content = content.pack('C*')
    #puts "handle_chunk: '#{content}', #{adler_digest}"
    adler_digest = ComputeAdlerDigest content if not adler_digest
    @file_sha1 << content
    sha1 = Digest::SHA1.new
    digest = sha1.hexdigest( content )
    @content.push( digest )
    @io.write_elem( :chunk, digest, content ) if not @io.exists? :chunk, digest

    if @adlers.key? adler_digest
      @adlers[ adler_digest ] << digest
    else
      @adlers[ adler_digest ] = Set.new( [ digest ] )
    end
  end
end

def open_writer
  ioservice = FileIOService.new
  ioservice.lock do
    adlers = AdlerDB::load
    w = SplitAndWriteChunks.new( ioservice, adlers )
    yield w
    AdlerDB::save adlers
  end
end

def save_file(writer, filename)
  File.open(filename, 'r') do |file|
     print 'Storing file: ', filename, "..."
     sha = writer.save_file(file)
     print " done, sha=#{sha}\n"
     sha
   end
end

def save_element(writer, name)
  if File.file? name
    save_file( writer, name )
  elsif File.directory? name
    save_dir( writer, name )
  else
    raise
  end
end

def save_dir(writer, dirname)
  content = []
  print 'Storing directory: ', dirname, "...\n"
  Dir.foreach(dirname).sort.each do |filename|
    if filename != '.' and filename != '..'
      path = File.join(dirname, filename)
      s = File.stat(path)
      content << [ if s.directory? then 1 else 0 end,
                   s.mode.to_s(8)[-3..-1], 
                   save_element(writer, File.join(dirname, filename)),
                   filename
                 ].join(' ')
    end
  end
  sha = Digest::SHA1.new
  content_str = content.join("\n")+"\n"
  digest = sha.hexdigest( content_str )
  writer.io.write_elem( :dir, digest, content_str )
  print dirname, " done sha=#{digest}\n"
  digest
end

def save(files)
  open_writer do |writer|
    files.each {|filename| save_element(writer, filename)}
  end
end

save ARGV

