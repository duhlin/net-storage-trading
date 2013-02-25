require 'openssl'

ChunkSize=50
StoreDir = 'store'

def chunk_dirname(sha1)
  StoreDir + '/' + sha1[0...2]
end

def chunk_filename(sha1)
  chunk_dirname( sha1 ) + '/' + sha1[2..-1]
end

def read_file(sha)
  File.open( chunk_filename(sha) ).each_line do |line|
    File.open( chunk_filename(line.strip) ).each_line {|l| print l}
  end
end

puts read_file(ARGV.pop)
