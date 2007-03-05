#!/usr/bin/ruby
$:.push('ai/task/')
require 'door.rb'
require 'explore.rb'
require 'fight.rb'
require 'fixhunger.rb'
require 'randomwalk.rb'

class TaskHandler
  def initialize()
    @tasks =
    [
      [2000, TaskFixHunger.new() ], # 1600 if Weak, 2000 if Fainting
      [1000, TaskFight.new()     ],
      [ 200, TaskDoor.new()      ],
      [ 100, TaskExplore.new()   ],
      [   1, TaskRandomWalk.new()],
    ]
  end

  # This runs the task with the highest priority. If that task's run returns a
  # false value, run the next-highest-priority task, and so on.
  def next_task()
    @tasks.map {|task| [task[0] * task[1].priority(), task[1]] }.
      sort {|a, b| b[0] <=> a[0]}.
      each do |task_array|
        debug("Running #{task_array[1].class.to_s} which has priority #{task_array[0]}")
        break if task_array[1].run()
    end
  end
end

