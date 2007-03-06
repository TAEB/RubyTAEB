#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskSearch < BaseTask
  def initialize()
    @path = ""
  end

  def priority()
    @path = "" if $map.updated_this_turn # Explore will kick in
    return 1 if @path.length > 0

    @path = $map.path_to_best_match($hero.x, $hero.y) do |x, y, path|
      searches_left = $map.at(x, y).searches_left(:sum)

      # finish searching before moving on
      next true if searches_left > 0 and path.length == 0

      path.length > 0 ? (2.0*searches_left) / path.length : searches_left
    end

    # @path == "" is okay, it just means we're standing on the best square
    if @path == nil
      raise "E002: path is nil from path_to_best_match in TaskSearch.priority -- bug in path_to_best_match?"
    end

    x1, y1 = $map.each_step_in_path(@path) do |x, y|
      $map.at(x, y).debug_color = "\e[1;36m"
    end

    @path += "s" * $map.at(x1, y1).searches_left(:max)
    debug("Search path: #{@path}")
    @path.reverse!
    return 1
  end

  def pick_move()
    if @path.length > 0
      ret = @path[-1].chr
      @path.chop!

      if ret == "s"
        $map.each_adjacent_tile do |tile|
          tile.searched += 1
        end
      end

      return ret
    end
    nil
  end
end


