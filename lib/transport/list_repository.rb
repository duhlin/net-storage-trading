#!/usr/bin/env ruby

def join(path1, path2)
	if path1 and path2
		File.join(path1, path2)
	elsif path1
		path1
	elsif path2
		path2
	end
end

def listdir(repository, subdir=nil)
	dir = join(repository, subdir)
	Dir.foreach(dir).sort.each do |e|
		#ignore . and ..
		if e != "." and e != ".."
			f = File.join(dir, e)
			if File.directory? f 
				listdir repository, join(subdir, e)
			elsif File.file? f
				STDOUT << "#{join(subdir,e)}\n"
			end
		end
	end
end

repository = ARGV[0]
listdir(repository)
