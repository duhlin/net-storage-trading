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

  def read_elem(type, sha, &block)
    raise if not exists? type, sha
    yield @store[ type ][sha ]
  end
end

def ComputeSHADigest(s)
  sha = Digest::SHA1.new
  sha << s
  sha.hexdigest
end

def ComputeAdlerDigest(s)
  a = Adler32.new 0
  a << s
  a.digest.to_s(16)
end

def CheckChunks(adlers, list)
  list.each do |chunk|
    adler = ComputeAdlerDigest chunk
    assert( (adlers.has_key? adler), "#{chunk}: #{adler} not found in #{adlers}" )
    assert( adlers[adler].member? ComputeSHADigest chunk )
  end 
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
    expected_chunks = ['test ', 'co', 'ntent']
    expected_chunks_sha = expected_chunks.map{|s| ComputeSHADigest s}
    #A. Each of the chunk is named with the sha on its content
    expected_chunks_sha.each{|sha| assert( @ioservice.exists? :chunk, sha )}
    
    #B. The filename is retrieved from the sha of the whole string
    file_sha = ComputeSHADigest 'test content'
    assert( @ioservice.exists? :file, file_sha )
    #C. The file lists all its chunks
    @ioservice.read_elem(:file, file_sha) do |c|
      c.each_line.zip(expected_chunks_sha).each{ |l, sha| assert_equal(l.strip, sha) }
    end
    #D. the adlers directory should be filled with the adler32 code of each chunk
    CheckChunks( @adlers, expected_chunks )
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

  #When something is added at the end, all the existing chunks are reused
  def test_reuse_existing_chunks_when_append
    @writer.save_file('test content') 
    CheckChunks @adlers, ['test ', 'co', 'ntent']
    @writer.save_file('test content updated') 
    CheckChunks @adlers, ['test ', 'co', 'ntent', ' up', 'dated']
  end
  
  #when something is added at the beginning, all the existing chunks are reused
  def test_reuse_existing_chunks_when_prepend
    @writer.save_file('test content') 
    CheckChunks @adlers, ['test ', 'co', 'ntent']
    @writer.save_file('a new test content') 
    CheckChunks @adlers, ['a new', ' ', 'test ', 'co', 'ntent'] 
  end

  #when something is inserted in the middle, all full chunks (with size @ChunkSize) are reused
  def test_reuse_existing_chunks_when_inserted
    @writer.save_file('test with some content') 
    CheckChunks @adlers, ['test ', 'with ', 'some ', 'co', 'ntent']
    @writer.save_file('test without any content') 
    CheckChunks @adlers, ['test ', 'witho', 'ut an', 'y co', 'ntent']
  end
end


