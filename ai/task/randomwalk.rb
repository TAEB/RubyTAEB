#!/usr/bin/ruby
require 'base.rb'

class TaskRandomWalk < BaseTask
  def initialize()
  end

  def priority()
    0
  end

  def pick_move()
    "hjklyubn"[rand(8)].chr
  end
end


