require_relative('reader')
require_relative('ioservice')

class Index
  def initialize(io)
    @io = io
    @chunks = Hash.new do |h,k| 
      raise KeyError, "WARNING: chunk #{k} not found"
      []
    end
    @files = Hash.new do |h,k|
      raise KeyError, "WARNING: file #{k} not found"
      []
    end
    @trees = Hash.new do |h,k|
      raise KeyError, "WARNING: tree #{k} not found"
      []
    end
  end

  def index_all
    load_chunks
    index_chunks_by_file
    index_file_and_trees_by_tree
    index_trees_by_root
  end

  def orphans
    { 
      :chunk => @chunks.select{ |k,v| v.empty? },
      :file  => @files.select{ |k,v| v.empty? },
      :tree  => @trees.select{ |k,v| v.empty? },
    }
  end

  def load_chunks
    @io.list_elem(:chunk) {|chunk_sha| @chunks[chunk_sha] = []}
  end

  def index_chunks_by_file
    @io.list_elem(:file) do |file_sha|
      @files[file_sha] = []
      file_foreach_chunk(@io, file_sha) do |chunk_sha|
        begin
          @chunks[ chunk_sha ] << file_sha
        rescue KeyError => e
          print "#{e.message} but referred by file: #{file_sha}\n"
        end
      end
    end
  end

  def index_file_and_trees_by_tree
    @io.list_elem(:tree) do |tree_sha|
      @trees[tree_sha] = []
    end
    
    @io.list_elem(:tree) do |tree_sha|
      tree_foreach(@io, tree_sha) do |file|
        if file['is_directory?'] == '1'
          begin
            @trees[ file['sha'] ] << tree_sha
          rescue KeyError => e
            print "#{e.message} but referred by tree: #{tree_sha}\n"
          end
        else
          begin
            @files[ file['sha'] ] << tree_sha
          rescue KeyError => e
            print "#{e.message} but referred by tree: #{tree_sha}\n"
          end
        end
      end
    end
  end

  def index_trees_by_root
    @io.list_elem(:root) do |root_sha|
      begin
        @trees[ root_sha ] << root_sha
      rescue KeyError => e
        print "#{e.message} but referred by tree: #{tree_sha}\n"
      end
    end
  end

end


io = FileIOService.new
io.lock do
  index = Index.new(io)
  index.index_all
  index.orphans.each{|type, orphans| print "#{type}\n#{orphans}\n\n"}
end

