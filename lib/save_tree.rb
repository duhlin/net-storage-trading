require 'openssl'
require 'set'
require 'ioservice'
require 'gen_keys'
require 'adler32'
require 'adler_storage'

class SplitAndWriteChunks
  attr_reader :io

  def initialize(ioservice, adlers, chunksize = 1024*512)
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
  ioservice = FileIOService.create( GetKeys() )
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
    save_tree( writer, name, writer.io.dir_with_stats(name) )
  else
    raise
  end
end

def save_tree(writer, dirname, subfiles)
  content = []
  print 'Storing directory: ', dirname, "...\n"
  subfiles.each do |stats|
    filename = stats[ :filename ]
    content << [ if stats[ :directory? ] then 1 else 0 end,
                 stats[ :mode ], 
                 save_element( writer, File.join(dirname, filename) ),
                 filename
               ].join(' ')
  end
  sha = Digest::SHA1.new
  content_str = content.join("\n")+"\n"
  digest = sha.hexdigest( content_str )
  writer.io.write_elem( :tree, digest, content_str )
  print dirname, " done sha=#{digest}\n"
  digest
end

def save_root(files)
  open_writer do |writer|
    files.each do |path| 
      dirname = File.dirname(path)
      filename = File.basename(path)
      digest = save_tree( writer, dirname, [writer.io.get_stats(dirname, filename)] )
      writer.io.declare_root( digest )
    end
  end
end

save_root ARGV

