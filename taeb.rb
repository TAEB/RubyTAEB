#!/usr/bin/ruby
require 'interface/telnet.rb'
password = File.new("password.txt").readline

connection = Telnet.new()
commands = ["l", "TAEB\n", password + "\n", "pnmmn", "    ", "#quit\n", "y", "          "]

for command in commands
  for c in command.split(//)
    puts "send('" + c + "')" unless command == commands[2]
    connection.send_and_recv(c)
  end
end

