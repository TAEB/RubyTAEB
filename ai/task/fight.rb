#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskFight < BaseTask
  def initialize()
    @direction = nil
  end

  def adjacent_fightable?()
    $map.each_direction do |dx, dy|
      if $map.at_delta(dx, dy).monster?
        @direction = $map.move_with_delta(dx, dy)
        return true
      end
    end
    false
  end

  def priority()
    adjacent_fightable?() ? 1 : 0
  end

  def pick_move()
    "F" + @direction
  end
end

