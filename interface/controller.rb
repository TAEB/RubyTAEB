#!/usr/bin/ruby
require 'interface/telnet.rb'
require 'interface/vt.rb'

$to_screen = true

class Controller
  attr_reader :vt, :connection

  def initialize()
    @vt = VT.new(80, 24)
    debug("Connecting to #{$server}")
    @connection = Telnet.new($server)

    login
  end

  def to_screen(str)
    if $to_screen
      print str
      $stdout.flush
    else
      @vt.display
    end
    str
  end

  def login()
    password = File.new("password.txt").readline
    to_screen(@connection.send_and_recv("l"))
    to_screen(@connection.send_and_recv($nick + "\n"))
    login_screen = to_screen(@connection.send_and_recv(password + "\n"))

    if login_screen !~ /Logged in as:/
      throw "Unable to log in!"
    end
    debug("Logged in to nethack.alt.org")

    sleep 1
    tmp = "p"
    while 1
      play_screen = send(tmp)
      tmp = ""

      if play_screen =~ /Shall I choose/
        debug("Creating a new character")
        send("y ")
        break
      elsif play_screen =~ /stale NetHack processes/
        debug("Got some stale processes; waiting 12s then trying again")
        sleep 12
        redo
      else
        debug("Restoring saved game")
        send("  ")
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

