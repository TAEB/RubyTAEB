#!/usr/bin/ruby

class BaseStyle
  def initialize()
  end

  def run()
    raise "Need to override BaseStyle.run"
  end

  def clear_screen()
    if $controller.vt.row(0) =~ /^Do you want your possessions identified\?/ or
       $controller.vt.row(0) =~ /^Do you want to see what you had when you died\?/
      debug("Oh no! We died!")
      $controller.send("y")
      while 1 # let the Disconnect exception break the loop
        $controller.send(" ")
        sleep 1
      end
    end

    if $controller.vt.row(0) =~ /^ *Things that are here: *$/ or
       $controller.vt.row(2) =~ /^ *Things that are here: *$/
      debug("Things that are here menu")
      $controller.send(" ")
      clear_screen()
    end

    if $controller.vt.to_s =~ /--More--/
         debug("I see a --More--!")
         $controller.send(" ")
         clear_screen()
    end
  end
end

