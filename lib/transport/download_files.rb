#!/usr/bin/env ruby

require "fileutils"

def download_file(stream, dir)
	filename = stream.readline.strip
	dirname = File.join( dir, File.dirname( filename ) )
	Dir.mkdir( dirname ) unless Dir.exists? dirname

	size = stream.readline.to_i
	File.open(File.join(dir, filename), "w") do |f|
		f << stream.read(size)
	end
	stream.readline #read empty line at the end of file
end

repository = ARGV[0]
FileUtils.mkdir_p( repository ) unless Dir.exists? repository

while not STDIN.eof?
	download_file(STDIN, repository)
end
