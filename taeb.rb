#!/usr/bin/ruby

$:.push('interface', 'ai', 'ai/task')
require 'constants.rb'
require 'diagnostics.rb'
require 'controller.rb'
require 'map.rb'
require 'menu.rb'
require 'hero.rb'
require 'taskhandler.rb'

print "\e[H\e[2J" # clear the screen (should be removed soonish)

begin
  $controller = Controller.new()
  $hero = Hero.new()
  $map = Map.new()
  $taskhandler = TaskHandler.new()

  $taskhandler.clear_screen()
  while 1
    $map.update
    $taskhandler.next_task()
  end

rescue RuntimeError => err
  puts "Caught a runtime exception (#{err}). Exiting gracefully.."
rescue Interrupt
  # avoid stacktrace
end

