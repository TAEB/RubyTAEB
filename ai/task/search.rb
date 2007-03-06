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
      searches_left = 0
      $map.each_direction do |dx, dy|
        t = $map.at(x+dx, y+dy)
        next unless t.scenery == "|" or t.scenery == "-" or t.scenery == "\0"
        next if t.searched >= 12

        # don't search walls next to doors or in corners
        if t.scenery == "|" or t.scenery == "-"
          adjacent_vert = 0
          adjacent_horiz = 0
          $map.each_adjacent_tile_to(x+dx, y+dy) do |tile|
            adjacent_vert += 1 if tile.scenery == "|"
            adjacent_horiz += 1 if tile.scenery == "-"
          end
          next if t.scenery == "-" and adjacent_vert == 1 and adjacent_horiz == 1
          next if t.scenery == "-" and adjacent_horiz == 0
          next if t.scenery == "|" and adjacent_vert == 0
        end

        searches_left += 12 - t.searched
      end

      # finish searching before moving on
      next true if searches_left > 0 and path.length == 0

      path.length > 0 ? (searches_left / (path.length*1.0)) : searches_left
    end

    # @path == "" is okay, it just means we're standing on the best square
    if @path == nil
      raise "E002: path is nil from path_to_best_match in TaskSearch.priority -- bug in path_to_best_match?"
    end

    @path += "s" * 11
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


