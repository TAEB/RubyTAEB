#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskFight < BaseTask
  def initialize()
    @direction = nil
  end

  def priority()
    @direction = adjacent_fightable_direction()
    @direction ? 1 : 0
  end

  def pick_move()
    "F" + @direction
  end
end

