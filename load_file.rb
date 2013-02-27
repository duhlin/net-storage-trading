require 'openssl'
require_relative 'ioservice'

ReadSize=50

def read_file(io, sha)
  io.read_elem(:file, sha) do |file|
    file.each_line do |line|
      io.read_elem(:chunk, line.strip) do |chunk_file|
        chunk_file.each(ReadSize) {|buf| yield buf}
      end
    end
  end 
end

io = FileIOService.new

sha = ARGV.pop
output_file = ARGV.pop

File.open( ouput_file, 'w' ) do |output|
  read_file(io, sha){ |i| output.write(i) }
end

