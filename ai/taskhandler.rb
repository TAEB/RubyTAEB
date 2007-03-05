#!/usr/bin/ruby
$:.push('ai/task/')

class TaskHandler
  def initialize()
    @tasks = []
  end

  def next_task()
    chosen_task = nil
    highest_priority = nil

    @tasks.each do |task|
      priority = task.priority()

      if highest_priority == nil or priority > highest_priority
        highest_priority = priority
        chosen_task = task
      end
    end

    chosen_task.run()
  end
end

