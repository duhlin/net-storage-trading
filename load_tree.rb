require 'openssl'
require 'fileutils'
require_relative 'ioservice'

ReadSize=50

def read_file(io, sha)
  io.read_elem(:file, sha) do |file|
    file.each_line do |line|
      line = line.strip
      if not line.empty?
        io.read_elem(:chunk, line) do |chunk_file|
          chunk_file.each(ReadSize) {|buf| yield buf}
        end
      end
    end
  end 
end

def load_file(io, sha, filename, mode, outdir)
  output_file = File.join(outdir, filename)
  print "loading file #{sha} into #{output_file}\n"
  File.open( output_file, 'w' ) do |output|
    read_file(io, sha){ |i| output.write(i) }
  end
  File.chmod( mode.oct, output_file )
end

def load_dir(io, sha, outdir)
  print "loading directory #{sha} into #{outdir}\n"
  io.read_elem(:dir, sha) do |dir_file|
    FileUtils.mkdir_p outdir
    r = Regexp.new '(?<is_directory>\d) (?<mode>\d{3}) (?<sha>\h{40}) (?<filename>.*)'
    dir_file.each_line do |line|
      l = r.match(line)
      if l 
        if l['is_directory'] == '1'  
          load_dir( io, l['sha'], File.join(outdir, l['filename']) )
        else
          load_file( io, l['sha'], l['filename'], l['mode'], outdir )
        end
      end
    end
  end
end

sha = ARGV[0]
outdir = ARGV[1]

io = FileIOService.new
load_dir(io, sha, outdir)
