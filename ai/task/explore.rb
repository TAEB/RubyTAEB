#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskExplore < BaseTask
  def initialize()
    @path = ""
    @needs_updating = false
  end

  def priority()
    @needs_updating = false if $map.updated_this_turn
    return 0 if @needs_updating

    @path = "" if $map.updated_this_turn
    return 1 if @path.length > 0

    @path = $map.path_to_first_match($hero.x, $hero.y) do |x, y, path|
      $map.at(x, y).stepped_on == 0
    end

    # @path == "" doesn't make sense here because of course we've stepped on
    # the current square
    if @path == ""
      @needs_updating = true
      return 0
    end

    debug("Explore path: #{@path}") if @path.length > 3
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

