#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskDown < BaseTask
  def should_run?()
    return true if $controller.vt.to_s =~ />/
    return false
  end

  def pick_move()
      "_>.>"
  end
end

