#!/usr/bin/env ruby

STDIN.each do |filename|
	content = File.read(filename.strip)
	STDOUT << filename
	STDOUT << "#{content.size}\n"
	STDOUT << content
	STDOUT << "\n"
end

