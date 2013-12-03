#!/usr/bin/env ruby

$VERBOSE = false

def read_one_line( f )
  a = f.gets
  STDERR.puts "#{f}:#{a}" if $VERBOSE
  a
end

$BUFFER = ""

def signal_missing( l )
  STDERR.puts "signal_missing: #{l}" if $VERBOSE
  $BUFFER << l
  r, w, = IO.select( [STDIN], [STDOUT])
  if w #ready to write
    STDOUT.write( $BUFFER ) 
    $BUFFER = ""
  end
end

def open(filename)
	if filename == "-"
		return STDIN
	else
		return File.open(filename, "r")
	end
end

left  = open ARGV[0]
right = open ARGV[1]

left_line = read_one_line(left) 
right_line = read_one_line(right)
while left_line or right_line
  if not right_line.nil? and (left_line.nil? or left_line > right_line)
    signal_missing right_line
    right_line = read_one_line(right)
  elsif not left_line.nil? and (right_line.nil? or right_line > left_line)
    left_line = read_one_line(left)
  else #if left_line == right_line
    left_line = read_one_line(left) 
    right_line = read_one_line(right)
  end
end

