#!/usr/bin/ruby
require 'interface/telnet.rb'
require 'interface/vt.rb'

$to_screen = 1

class Controller
  attr_reader :vt, :connection

  def initialize()
    @vt = VT.new(80, 24)
    @connection = Telnet.new("nethack.alt.org")

    login
  end

  def to_screen(str)
    if $to_screen
      print str
      $stdout.flush
    end
    str
  end

  def login()
    password = File.new("password.txt").readline
    to_screen(@connection.send_and_recv("l"))
    to_screen(@connection.send_and_recv("TAEB\n"))
    login_screen = to_screen(@connection.send_and_recv(password + "\n"))

    if login_screen !~ /Logged in as:/
      throw "Unable to log in!"
    end

    sleep 1
    tmp = "p"
    while 1
      play_screen = send(tmp)
      tmp = ""

      if play_screen =~ /Shall I choose/
        send("y")
        break
      elsif play_screen =~ /stale NetHack processes/
        sleep 12
        redo
      else
        send(" ")
        break
      end
    end
  end

  def send(str)
    @vt.parse(to_screen(@connection.send_and_recv(str)))
    @vt.to_s
  end

  def at(x, y)
    @vt.at(x, y)
  end
end

