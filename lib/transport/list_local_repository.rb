#!/usr/bin/env ruby

def listdir(dir)
	Dir.foreach(dir).sort.each do |e|
		#ignore . and ..
		if e != "." and e != ".."
			if File.directory? e
				listdir( File.join(dir,e) )
			elsif File.file? e
				STDOUT << "#{e}\n"
			end
		end
	end
end

repository = ARGV[0]
listdir(repository)
