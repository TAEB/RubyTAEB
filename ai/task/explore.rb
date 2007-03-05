#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskExplore < BaseTask
  def initialize()
    @path = []
    @needs_updating = false
  end

  def priority()
    return 0 if @needs_updating

    @path = $map.path_to_first($hero.x, $hero.y) do |x, y, path|
      $map.stepped_on(x, y) == 0
    end

    if @path == nil
      @needs_updating = 1
      return 0
    end
    return 1
  end

  def pick_move()
    if @path.size > 0
      return @path.shift
    end
    nil
  end
end

