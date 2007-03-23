#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskEnsure < BaseTask
  def initialize()
    @direction = nil
  end

  def adjacent_unsure_direction()
    Map.each_direction do |dx, dy|
      if $map.at_delta(dx, dy).unsure
        return Map.move_with_delta(dx, dy)
      end
    end
    nil
  end

  def priority()
    @direction = adjacent_unsure_direction()
    @direction ? 1 : 0
  end

  def run()
    $controller.send("c")

    if $controller.vt.row(0) =~ /^You can't reach over the edge of the pit\./
      return false
    end

    $controller.send(@direction)

    dx, dy = Map.delta_with_move(@direction)

    $map.at_delta(dx, dy).unsure = false
    $map.updated_this_turn = 1

    if $controller.vt.row(0) =~ /^You (see|feel) no door there\./
      $map.at_delta(dx, dy).scenery = '.' # could be #, doesn't matter
    elsif $controller.vt.row(0) =~ /^Something's in the way\./
      # no-op
    elsif $controller.vt.row(0) =~ / stands in the way!/
      # no-op
    elsif $controller.vt.row(0) =~ /^This doorway has no door\./
      # no-op
    else
      raise "Unexpected TaskEnsure response: #{$controller.vt.row(0)}"
    end

    return true
  end
end


