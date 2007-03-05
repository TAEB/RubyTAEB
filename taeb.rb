#!/usr/bin/ruby

$:.push('interface', 'ai', 'ai/task')
require 'diagnostics.rb'
require 'controller.rb'
require 'map.rb'
require 'menu.rb'
require 'hero.rb'
require 'taskhandler.rb'

begin
  $controller = Controller.new()
  $hero = Hero.new()
  $map = Map.new()
  $taskhandler = TaskHandler.new()

  while 1
    if $controller.vt.row(0) =~ /^ *Things that are here: *$/
      debug("Things that are here menu")
      $controller.send(" ")
      redo
    end

    if $controller.vt.row(0) =~ /--More-- *$/ or
       $controller.vt.row(1) =~ /--More-- *$/
      debug("I see a --More--!")
      $controller.send(" ")
      redo
    end

    if $controller.vt.row(0) =~ /^Do you want your possessions identified\?/
      debug("Oh no! We died!")
      $controller.send("y")
      while 1 # let the Disconnect exception break the loop
        $controller.send(" ")
        sleep 1
      end
    end

    $map.update
    $taskhandler.next_task()
  end

rescue RuntimeError => err
  puts "Caught a runtime exception (#{err}). Exiting gracefully.."
rescue Interrupt
  # avoid stacktrace
end

