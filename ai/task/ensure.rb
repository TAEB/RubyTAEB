#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskEnsure < BaseTask
  def initialize()
    @direction = nil
  end

  def adjacent_unsure_direction()
    $map.each_direction do |dx, dy|
      if $map.at_delta(dx, dy).unsure
        return $map.move_with_delta(dx, dy)
      end
    end
    nil
  end

  def priority()
    @direction = adjacent_unsure_direction()
    @direction ? 1 : 0
  end

  def run()
    $controller.send("c" + @direction)
    dx, dy = $map.delta_with_move(@direction)
    $map.at_delta(dx, dy).unsure = false
    if $controller.vt.row(0) =~ /^You (see|feel) no door there\./
      $map.at_delta(dx, dy).scenery = '.' # could be #, doesn't matter
    elsif $controller.vt.row(0) =~ /^Something's in the way\./
      # no-op
    elsif $controller.vt.row(0) =~ / stands in the way!/
      # no-op
    else
      raise "Unexpected TaskEnsure response: #{$controller.vt.row(0)}"
    end
  end
end


