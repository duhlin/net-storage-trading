require_relative 'save_tree'
require_relative 'ioservice'
require_relative 'C_adler32/adler32'
require 'test/unit'
require 'openssl'

class TestIOService
  attr_reader :store
  def initialize
    @store = Hash.new
  end
  
  def exists?(type, sha)
    @store.has_key? type and @store[type].has_key? sha
  end

  def write_elem(type, sha, content)
    #puts content if type == :chunk
    @store[ type ] = Hash.new if not @store.has_key? type
    raise if @store[ type ].has_key? sha
    @store[ type ][ sha ] = content
  end

  def read_elem(type, sha)
    raise if not exists? type, sha
    yield @store[ type ][ sha ]
  end
end

def ComputeSHADigest(s)
  sha = Digest::SHA1.new
  sha << s.each_byte.to_a.pack('C*')
  sha.hexdigest
end

def ComputeAdlerDigest(s)
  a = Adler32.new 0
  a << s
  a.digest.to_s(16)
end

def CheckChunksInAdlerDirectory(adlers, list)
  list.each do |chunk|
    adler = ComputeAdlerDigest chunk
    assert( (adlers.has_key? adler), "#{chunk}: #{adler} not found in #{adlers}" )
    assert( adlers[adler].member? ComputeSHADigest chunk )
  end 
end

def CheckFileChunks(io, sha, chunks)
  io.read_elem(:file, sha) do |file|
    assert_equal( chunks.map{|e| ComputeSHADigest e}, file.each_line.map{|l| l.strip} )
  end
end

def CheckFile(writer, io, adlers, content, chunks)
    sha = writer.save_file( content ) 
    CheckFileChunks io, sha, chunks
    CheckChunksInAdlerDirectory adlers, chunks
end

class Test_save_tree < Test::Unit::TestCase
  def setup
    @chunkSize = 5
    @ioservice = TestIOService.new
    @adlers = {} #empty dir
    @writer = SplitAndWriteChunks.new( @ioservice, @adlers, @chunkSize )
  end

  #when saved, a file is split into chunks with the following requirements
  #A. Each of the chunks is named with the sha of its content.
  #B. The file is named with the sha of its content
  #C. The file lists the chunks its made of.
  #D. An adler directory is updated with the reference of the chunks
  def test_store_file
    #emulate the saving of a file whose content is 'test content'
    @writer.save_file('test content')
    #we expect three chunks for
    expected_chunks = ['test ', 'conte', 'nt']
    expected_chunks_sha = expected_chunks.map{|s| ComputeSHADigest s}
    #A. Each of the chunk is named with the sha on its content
    expected_chunks_sha.each{|sha| assert( @ioservice.exists? :chunk, sha )}
    
    #B. The filename is retrieved from the sha of the whole string
    file_sha = ComputeSHADigest 'test content'
    assert( @ioservice.exists?(:file, file_sha), "file not found: #{file_sha} in #{@ioservice.store[:file]}" )
    #C. The file lists all its chunks
    @ioservice.read_elem(:file, file_sha) do |c|
      c.each_line.zip(expected_chunks_sha).each{ |l, sha| assert_equal(l.strip, sha) }
    end
    #D. the adlers directory should be filled with the adler32 code of each chunk
    CheckChunksInAdlerDirectory( @adlers, expected_chunks )
  end

  #check that a same file is not stored twice
  def test_no_duplicated_file
    #emulate the saving of a file whose content is 'test content'
    @writer.save_file('test content')
    #an exception should be raised by ioservice if file is attempted to be saved twice
    assert_nothing_thrown do
      @writer.save_file('test content')
    end
  end

  #When something is added at the end, all the full existing chunks are reused
  def test_reuse_existing_chunks_when_append
    CheckFile @writer, @ioservice, @adlers, 'test content', ['test ', 'conte', 'nt']
    CheckFile @writer, @ioservice, @adlers, 'test content updated', ['test ', 'conte', 'nt', ' upda', 'ted']
  end
  
  #when something is added at the beginning, all the full existing chunks are reused
  def test_reuse_existing_chunks_when_prepend
    CheckFile @writer, @ioservice, @adlers, 'test content', ['test ', 'conte', 'nt']
    CheckFile @writer, @ioservice, @adlers, 'a new test content', ['a new', ' ', 'test ', 'conte', 'nt']
  end

  #when something is inserted in the middle, all full chunks (with size @ChunkSize) are reused
  def test_reuse_existing_chunks_when_inserted
    CheckFile @writer, @ioservice, @adlers, 'test content', ['test ', 'conte', 'nt']
    CheckFile @writer, @ioservice, @adlers, 'test with a content', ['test ', 'with ', 'a ', 'conte', 'nt']
  end

  #test save with funny char
  def test_exotic_char
    CheckFile @writer, @ioservice, @adlers, 
      "J'espère que ça va marcher", 
      "J'espère que ça va marcher".bytes.each_slice(@chunkSize).to_a.map{|a| a.pack('C*')} 
  end

  #test that chunks are reused if possible in a single save
  def test_reuse_single_file
    CheckFile @writer, @ioservice, @adlers, 'test tests test ', ['test ', 'tests', ' ', 'test ']
  end

  #When a tree is saved:
  #A. the tree file is named with the sha of its content
  #B. the tree file stores the list of the file in it
  #C. each file is normaly saved
  def test_save_tree
  end

end


