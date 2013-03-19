require 'openssl'

def chunk_foreach(io, sha, step)
  io.read_elem(:chunk, sha) do |chunk_file|
    sha_control = Digest::SHA1.new
    chunk_file.each(step) do |buf|
      yield buf
      sha_control << buf
    end
    raise if sha_control.hexdigest != sha
  end
end

def file_foreach(io, sha, step)
  io.read_elem(:file, sha) do |file|
    sha_control = Digest::SHA1.new
    file.each_line do |chunk_sha|
      chunk_sha = chunk_sha.strip
      if not chunk_sha.empty?
        chunk_foreach(io, chunk_sha, step) do |buf| 
          yield buf
          sha_control << buf
        end
      end
    end
    raise if sha_control.hexdigest != sha
  end
end


def dir_foreach(io, sha)
  #go through each tree entry and check the names
  io.read_elem(:dir, sha) do |dir_file|
    sha_control = Digest::SHA1.new
    r = Regexp.new '(?<is_directory>\d) (?<mode>\d{3}) (?<sha>\h{40}) (?<filename>.*)'
    dir_file.each_line do |line|
      l = r.match(line)
      yield l if l
      sha_control << line 
    end
    puts "failure: #{sha} != #{sha_control.hexdigest} - raise" if sha_control.hexdigest != sha
  end
end

