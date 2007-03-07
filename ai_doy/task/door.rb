#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskDoor < BaseTask
  def initialize()
    @direction = nil
  end

  def should_run?()
    @direction = adjacent_door_direction()
    @direction ? true : false
  end

  def pick_move()
    4.chr() + @direction
  end
end

