#!/usr/bin/ruby
require 'interface/telnet.rb'
require 'interface/vt.rb'

password = File.new("password.txt").readline
$vt = VT.new(80, 24)

def debug(t, s)
  if 1
    $vt.parse(s)
    print s
    $stdout.flush
  else
    puts t
  end
  s
end

begin
  server = "nethack.alt.org"
  debug("Connecting to #{server}.", '')
  connection = Telnet.new(server)
  debug("Logging in.",
        connection.send_and_recv("l") + connection.send_and_recv("TAEB\n"))

  logged_in = debug('', connection.send_and_recv(password + "\n"))
  if logged_in =~ /Logged in as:/
    puts "Successfully logged in."
  else
    throw "Unable to log in!"
  end

  new_or_save = debug('', connection.send_and_recv("p"))
  if new_or_save =~ /Shall I choose/
    puts "Starting a new character."
    debug('', connection.send_and_recv("nmmn  "))
  else
    puts "Restoring save file."
    debug('', connection.send_and_recv("   "))
  end

  while 1
    command = commands[rand(commands.size())]
    debug("Sending '#{command}'.", connection.send_and_recv(command))
  end

rescue RuntimeError => err
  puts "Caught a runtime exception (#{err}). Exiting gracefully.."
end

