#!/usr/bin/ruby
require 'ai/goal/base.rb'
require 'ai/prioritizedprog.rb'
require 'ai/task/randomwalk.rb'

class GoalFallback < BaseGoal
  def initialize()
    @pprogs = [
      #PrioritizedProg.new(1, TaskRandomWalk.new()),
      PrioritizedProg.new(1, TaskSearch.new()),
    ]
  end
end
