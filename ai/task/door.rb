#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskDoor < BaseTask
  def initialize()
    @direction = nil
  end

  def priority()
    @direction = adjacent_door_direction()
    @direction ? 1 : 0
  end

  def pick_move()
    4.chr() + @direction
  end
end

