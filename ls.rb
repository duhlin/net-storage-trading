require_relative('reader')
require_relative('ioservice')
require_relative('gen_keys')

def print_elem(sha, filename)
  print "#{sha} #{filename}\n"
end

def ls_tree(io, sha, root = './')
  print_elem(sha, root)
  tree_foreach(io, sha) do |elem|
    filename = File.join(root, elem['filename'])
    if elem['is_directory?'] == '1'
      ls_tree( io, elem['sha'], filename ) 
    else 
      print_elem( elem['sha'], filename )
    end
  end
end

io = FileIOService.create( GetKeys() )
io.lock do
  root_foreach(io) { |sha| ls_tree(io, sha) }
end

