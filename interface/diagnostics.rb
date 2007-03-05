#!/usr/bin/ruby

$debug_handle = File.open("debug.log", "a")

def debug(out)
  $debug_handle.puts(out)
end

debug("-" * 79)
# TODO: include the name of the ttyrec for this session

