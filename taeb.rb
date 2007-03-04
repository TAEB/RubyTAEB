#!/usr/bin/ruby
require 'interface/telnet.rb'
password = File.new("password.txt").readline

begin
  server = "nethack.alt.org"
  puts "Connecting to #{server}."
  connection = Telnet.new(server)

  puts "Logging in."
  connection.send_and_recv("l")
  connection.send_and_recv("TAEB\n")

  logged_in = connection.send_and_recv(password + "\n")
  if logged_in =~ /Logged in as:/
    puts "Successfully logged in."
  else
    throw "Unable to log in!"
  end

  new_or_save = connection.send_and_recv("p")
  if new_or_save =~ /Shall I choose/
    puts "Starting a new character."
    connection.send_and_recv("nmmn  ")
  else
    puts "Restoring save file."
    connection.send_and_recv("   ")
  end

  puts "Saving, since we don't know what we're doing yet."
  connection.send_and_recv("Sy")

rescue RuntimeError => err
  puts "Caught a runtime exception (#{err}). Exiting gracefully.."
end

