#!/usr/bin/ruby
require 'ai/goal/base.rb'
require 'ai/prioritizedprog.rb'
require 'ai/task/de_unsure.rb'

class GoalUpdateMap < BaseGoal
  def initialize()
    @pprogs = [
      PrioritizedProg.new(1, TaskDeUnsure.new()),
    ]
  end
end
