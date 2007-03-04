#!/usr/bin/ruby
require 'interface/controller.rb'
require 'interface/telnet.rb'
require 'interface/vt.rb'
require 'interface/map.rb'
require 'ai/task/explore.rb'
require 'ai/task/fight.rb'
require 'ai/task/opendoor.rb'
require 'ai/task/fixhunger.rb'
require 'ai/task/elbereth.rb'
require 'ai/hero.rb'

begin
  $controller = Controller.new()
  $hero = Hero.new()
  $task_explore = TaskExplore.new()
  $task_fight = TaskFight.new()
  $task_opendoor = TaskOpenDoor.new()
  $task_fixhunger = TaskFixHunger.new()
  $task_elbereth = TaskElbereth.new()
  $map = Map.new()

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

    $map.update

    redo if $task_fixhunger.run()
    redo if $task_elbereth.run()
    redo if $task_fight.run()
    redo if $task_opendoor.run()
    redo if $task_explore.run()
  end

rescue RuntimeError => err
  puts "Caught a runtime exception (#{err}). Exiting gracefully.."
end

