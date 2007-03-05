#!/usr/bin/ruby
$:.push('ai/task/')
require 'door.rb'
require 'eatfood.rb'
require 'elbereth.rb'
require 'explore.rb'
require 'fight.rb'
require 'fixhunger.rb'
require 'randomwalk.rb'
require 'search.rb'

class TaskHandler
  def initialize()
    @tasks =
    [
      [10000, TaskElbereth.new()  ], # <50% HP
      [ 2000, TaskFixHunger.new() ], # 1600 Weak, 2000 Fainting
      [ 1900, TaskEatFood.new()   ], # 1520 Hungry, 1710 Weak, 1900 Fainting
      [ 1000, TaskFight.new()     ], # adjacent monster
      [  200, TaskDoor.new()      ], # adjacent door
      [  100, TaskExplore.new()   ],
      [   50, TaskSearch.new()    ],
      [    1, TaskRandomWalk.new()],
    ]
  end

  # This runs the task with the highest priority. If that task's run returns a
  # false value, run the next-highest-priority task, and so on.
  # Warning: some tasks depend on having priority called each tick, so you can't
  # stop processing early (a possible optimization) unless priority is separated
  # from update
  def next_task()
    @tasks.map {|task| [task[0] * task[1].priority(), task[1]] }.
      sort {|a, b| b[0] <=> a[0]}.
      each do |task_array|
        debug("Running #{task_array[1].class.to_s} which has priority #{task_array[0]}")
        break if task_array[1].run()
    end
  end
end

