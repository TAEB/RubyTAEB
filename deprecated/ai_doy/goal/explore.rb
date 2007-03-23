#!/usr/bin/ruby
require 'ai/goal/base.rb'
require 'ai/prioritizedprog.rb'
require 'ai/task/door.rb'
require 'ai/task/explore.rb'
require 'ai/task/randomwalk.rb'
require 'ai/task/search.rb'

class GoalExplore < BaseGoal
  def initialize()
    @pprogs = [
      PrioritizedProg.new(3, TaskDoor.new()   ),
      PrioritizedProg.new(2, TaskExplore.new()),
      PrioritizedProg.new(1, TaskSearch.new() ),
    ]
  end
end
