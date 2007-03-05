#!/usr/bin/ruby

class TaskRandomWalk
  def initialize()
  end

  def priority()
    0
  end

  def pick_move()
    "hjklyubn"[rand(8)].chr
  end
end


