#!/usr/bin/ruby
require 'interface/telnet.rb'
password = File.new("password.txt").readline

connection = Telnet.new()
output = connection.send_and_recv("lTAEB\n" + password + "\n")
print output

