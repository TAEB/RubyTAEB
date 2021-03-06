#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskExplore < BaseTask
  def initialize()
    @path = ""
    @needs_updating = false
  end

  def should_run?()
    $map.at($hero.x, $hero.y).debug_color = nil
    @needs_updating = false if $map.updated_this_turn
    return false if @needs_updating

    @path = "" if $map.updated_this_turn
    return true if @path.length > 0

    @path = $map.path_to_first_match($hero.x, $hero.y) do |x, y, path|
      not $map.at(x, y).explored
    end

    # @path == "" doesn't make sense here because of course we've explored
    # the current square
    if @path == ""
      @needs_updating = true
      return false
    end

    x, y = $hero.x, $hero.y
    @path.each_byte do |dir|
      dx, dy = $map.delta_with_move(dir.chr)
      x += dx
      y += dy
      $map.at(x, y).debug_color = "\e[1;35m"
    end

    debug("Explore path: #{@path}") if @path.length > 3
    @path.reverse!
    return true
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

