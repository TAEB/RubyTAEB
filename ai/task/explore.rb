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
      not $map.at(x, y).explored
    end

    # @path == "" doesn't make sense here because of course we've explored
    # the current square
    if @path == ""
      @needs_updating = true
      return 0
    end

    $map.each_tile do |tile|
      tile.on_explore_path     = tile.on_search_path     =
      tile.explore_destination = tile.search_destination = false
    end

    x1, y1 = Map.each_step_in_path(@path) do |x, y|
      $map.at(x, y).on_explore_path = true
    end
    $map.at(x1, y1).explore_destination = true

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

