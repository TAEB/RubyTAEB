#!/usr/bin/ruby
require 'ai/goal/base.rb'
require 'ai/prioritizedprog.rb'
require 'ai/task/elbereth.rb'
require 'ai/goal/fixhunger.rb'

class GoalSurvive < BaseGoal
  def initialize()
    @pprogs = [
      PrioritizedProg.new(2, TaskElbereth.new() ),
      PrioritizedProg.new(1, GoalFixHunger.new()),
    ]
  end
end
