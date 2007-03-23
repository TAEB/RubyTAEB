#!/usr/bin/ruby
require 'ai/task/base.rb'


class TaskSearch < BaseTask
  @@search_time = 2

  def initialize()
    @path = ""
  end

  def should_run?()
    @path = "" if $map.updated_this_turn # Explore will kick in
    return true if @path.length > 0

    valid_path = false
    @path = $map.path_to_best_match($hero.x, $hero.y) do |x, y, path|
      searches_left = 0
      $map.each_direction do |dx, dy|
        t = $map.at(x+dx, y+dy)
        next unless t.scenery == "|" or t.scenery == "-" or t.scenery == "\0"
        next if t.searched >= @@search_time
        searches_left += @@search_time - t.searched
      end
      score = path.length > 0 ? (searches_left / (path.length*1.0)) : searches_left
      if score > 0
          valid_path = true
      end
    end

    if not valid_path
      # keep searching if we haven't found the stairs
      @@search_time += @@search_time unless $controller.vt.to_s =~ />/
      return false
    end
    # @path == "" is okay, it just means we're standing on the best square
    if @path == nil
      raise "E002: path is nil from path_to_best_match in TaskSearch.priority -- bug in path_to_best_match?"
    end

    @path += "s" * @@search_time
    debug("Search path: #{@path}")
    @path.reverse!
    return true
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


