#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskRandomWalk < BaseTask
  def priority()
    1
  end

  def pick_move()
    "hjklyubn"[rand(8)].chr
  end
end


