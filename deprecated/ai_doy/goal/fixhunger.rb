#!/usr/bin/ruby
require 'ai/goal/base.rb'
require 'ai/prioritizedprog.rb'
require 'ai/task/eat.rb'
require 'ai/task/prayforfood.rb'

class GoalFixHunger < BaseGoal
  def tasks()
    if $hero.prayertimeoutmax < 0 or
       ($controller.vt.row(23) =~ /Faint/ and $hero.prayertimeoutmin < 0)
      return [
          PrioritizedProg.new(2, TaskPrayForFood.new()),
          PrioritizedProg.new(1, TaskEat.new()        ),
      ]
    else
      return [
          PrioritizedProg.new(2, TaskEat.new()        ),
          PrioritizedProg.new(1, TaskPrayForFood.new()),
      ]
    end
  end
end
