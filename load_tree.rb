require 'openssl'
require 'fileutils'
require_relative 'ioservice'
require_relative 'reader'

ReadSize=50


def load_file(io, sha, filename, mode, outdir)
  output_file = File.join(outdir, filename)
  print "loading file #{sha} into #{output_file}\n"
  File.open( output_file, 'w' ) do |output|
    file_foreach(io, sha, ReadSize) { |buf| output.write(buf) }
  end
  File.chmod( mode.oct, output_file )
end

def load_tree(io, sha, outdir)
  print "loading tree #{sha} into #{outdir}\n"
  FileUtils.mkdir_p outdir
  tree_foreach(io, sha) do |l|
    if l['is_directory?'] == '1'  
      load_tree( io, l['sha'], File.join(outdir, l['filename']) )
    else
      load_file( io, l['sha'], l['filename'], l['mode'], outdir )
    end
  end
end

sha = ARGV[0]
outdir = ARGV[1]

io = FileIOService.new
io.lock{ load_tree(io, sha, outdir) }
