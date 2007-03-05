#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskDoor < BaseTask
  def initialize()
    @direction = nil
  end

  def adjacent_door?()
    $map.each_direction do |dx, dy|
      if $map.at_delta(dx, dy).scenery == ']'
        @direction = $map.move_with_delta(dx, dy)
        return true
      end
    end
    false
  end

  def priority()
    adjacent_door?() ? 1 : 0
  end

  def pick_move()
    "k" + @direction
  end
end

