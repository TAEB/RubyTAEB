#!/usr/bin/ruby
require 'ai/goal/base.rb'
require 'ai/prioritizedprog.rb'
require 'ai/task/down.rb'

class GoalDescend < BaseGoal
  def initialize()
    @pprogs = [
      PrioritizedProg.new(1, TaskDown.new()),
    ]
  end
end
