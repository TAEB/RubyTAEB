#!/usr/bin/ruby
$:.push('ai/task/')

class TaskHandler
  def initialize()
    @tasks = []
  end

  # This runs the task with the highest priority. If that task's run returns a
  # false value, run the next-highest-priority task, and so on.
  def next_task()
    @tasks.map {|t| [t.priority, t]}.sort.reverse.each do |task_array|
      break if task_array[1].run
    end
  end
end

