#!/usr/bin/ruby
$:.push('ai/task/')
require 'randomwalk.rb'

class TaskHandler
  def initialize()
    @tasks =
    [
      TaskRandomWalk.new(),
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

