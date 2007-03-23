#!/usr/bin/ruby
require 'ai/goal/base.rb'
require 'ai/prioritizedprog.rb'
require 'ai/task/fight.rb'
#require 'ai/task/flee.rb'

class GoalHandleMonster < BaseGoal
  def initialize()
    @pprogs = [
      PrioritizedProg.new(2, TaskFight.new()),
      #PrioritizedProg.new(1, TaskFlee.new() ),
    ]
  end
end
