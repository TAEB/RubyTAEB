#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskFight < BaseTask
  def initialize()
    @direction = nil
  end

  def should_run?()
    @direction = adjacent_fightable_direction()
    # ignore floating eyes, gas spores, and shks (among other things)
    if not @direction or
       $map.at_direction(@direction).monster == 'e' or
       $map.at_direction(@direction).monster == '@'
      return false
    end
    return true
  end

  def pick_move()
    "F" + @direction
  end
end

