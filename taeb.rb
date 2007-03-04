#!/usr/bin/ruby
require 'interface/controller.rb'
require 'interface/telnet.rb'
require 'interface/vt.rb'
require 'ai/task/explore.rb'
require 'ai/task/fight.rb'
require 'ai/task/opendoor.rb'
require 'ai/hero.rb'

begin
  $controller = Controller.new()
  $hero = Hero.new()
  $task_explore = TaskExplore.new()
  $task_fight = TaskFight.new()
  $task_opendoor = TaskOpenDoor.new()

  while 1
    if $controller.vt.to_s =~ /--More--/
      $stderr.puts "I see a --More--!"
      $controller.send(" ")
      redo
    end

    redo if $task_fight.run()
    redo if $task_opendoor.run()
    redo if $task_explore.run()
  end

rescue RuntimeError => err
  puts "Caught a runtime exception (#{err}). Exiting gracefully.."
end

