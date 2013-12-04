#!/usr/bin/env ruby

STDOUT.binmode

repository = ARGV[0]
STDIN.each do |filename|
	f = File.open( File.join(repository,filename.strip), "rb" )
	content = f.read
	STDOUT << filename
	STDOUT << "#{content.size}\n"
	STDOUT.write content
	STDOUT << "\n"
end

