#!/usr/bin/ruby
require 'interface/telnet.rb'
require 'interface/vt.rb'

$to_screen = true

class Controller
  attr_reader :vt, :connection

  def initialize()
    @logged_in = false
    @vt = VT.new(80, 24)
    debug("Connecting to #{$server}")
    @connection = Telnet.new($server)

    @ttyrec_name = "ttyrec/" + Time.now.strftime("%Y-%m-%d.%H:%M:%S") + ".ttyrec"
    @ttyrec_handle = File.new(@ttyrec_name, "w")
    @debug_ttyrec_name = "ttyrec/" + Time.now.strftime("%Y-%m-%d.%H:%M:%S") + "-debug.ttyrec"
    @debug_ttyrec_handle = File.new(@debug_ttyrec_name, "w")

    login
    @logged_in = true
  end

  def to_screen(str)
    taeb_vision = $map.display

    print_to_ttyrec(str, @ttyrec_handle)
    print_to_ttyrec(taeb_vision, @debug_ttyrec_handle) if taeb_vision

    if $to_screen or not @logged_in
      print str
    else
      print taeb_vision if taeb_vision
    end

    $stdout.flush
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

  def print_to_ttyrec(output, handle)
    return if output.length == 0
    t = Time.now
    header = [t.tv_sec, t.tv_usec, output.length].pack("VVV")
    handle.print(header + output)
    handle.flush()
  end

  def close_ttyrec(handle)
    handle.flush()
    handle.close()
  end
end

