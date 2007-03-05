#!/usr/bin/ruby
require 'interface/controller.rb'
require 'interface/telnet.rb'
require 'interface/vt.rb'
#require 'interface/map.rb'
require 'interface/menu.rb'
require 'ai/hero.rb'

begin
  $controller = Controller.new()
  $hero = Hero.new()
  #$map = Map.new()

  while 1
    if $controller.vt.to_s =~ /--More--/
      $stderr.puts "I see a --More--!"
      $controller.send(" ")
      redo
    end
    if $controller.vt.to_s =~ /^Do you want your possessions identified\?/
      $stderr.puts "Oh no! We died!"
      $controller.send("y")
      while 1 # let the Disconnect exception break the loop
        $controller.send(" ")
        sleep 1
      end
    end

    #$map.update

    sleep 2
    $controller.send("O")
    menu = Menu.new()
    menu.select_all_matches(/auto/)
    menu.toggle_all_matches(/pickup/)
    menu.unselect_all_matches(/pickup_types/)
    menu.execute()

    # handle pickup_burden menu
    menu = Menu.new()
    menu.single_select(/unencumbered/)

    $controller.send("Sy  ")
  end

rescue RuntimeError => err
  puts "Caught a runtime exception (#{err}). Exiting gracefully.."
rescue Interrupt
  # avoid stacktrace
end

