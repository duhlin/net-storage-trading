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

local = File.open(ARGV[0], "r")

stdin_line = read_one_line(STDIN) 
local_line = read_one_line(local)
while stdin_line or local_line
  if not local_line.nil? and (stdin_line.nil? or stdin_line > local_line)
    signal_missing local_line
    local_line = read_one_line(local)
  elsif not stdin_line.nil? and (local_line.nil? or local_line > stdin_line)
    stdin_line = read_one_line(STDIN)
  else #if stdin_line == local_line
    stdin_line = read_one_line(STDIN) 
    local_line = read_one_line(local)
  end
end

