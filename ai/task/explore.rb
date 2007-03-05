#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskExplore < BaseTask
  def initialize()
    @path = ""
    @needs_updating = false
  end

  def priority()
    return 0 if @needs_updating

    @path = $map.path_to_first_match($hero.x, $hero.y) do |x, y, path|
      $map.at(x, y).stepped_on == 0
    end

    if @path == nil
      @needs_updating = 1
      return 0
    end

    @path.reverse!
    return 1
  end

  def pick_move()
    if @path.length > 0
      ret = @path[-1].chr
      @path.chop!
      return ret
    end
    nil
  end
end

