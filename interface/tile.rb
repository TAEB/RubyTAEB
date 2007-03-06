#!/usr/bin/ruby

class Tile
  attr_accessor :scenery, :stepped_on, :searched, :explored, :unsure, :debug_color
  attr_reader :x, :y, :z

  def initialize(z, x, y)
    @scenery = nil
    @items = nil
    @monster = nil
    @debug_color = nil
    @stepped_on = 0
    @searched = 0
    @explored = false
    @unsure = false

    @z = z
    @x = x
    @y = y
  end

  def Tile.scenery?(glyph)
    case glyph
    when ".", "#", ",", "]", ">", "<", "{", "_", "\\", "^", "0"
      true
    when "|", "-", "}"
      true
    else
      false
    end
  end

  def Tile.walkable?(glyph)
    case glyph
    when ".", "#", ",", "]", ">", "<", "{", "_", "\\", "^"
      true
    else
      false
    end
  end

  def Tile.monster?(glyph)
    case glyph
    when "a".."z", "A".."Z", "@", "'", "&", ";", ":", "~"
      true
    else
      false
    end
  end

  def Tile.walk_penalty(glyph)
    case glyph
    when "^"
      1000
    when ".", "#", ",", "]", ">", "<", "{", "_", "\\", "^"
      1
    else
      nil
    end
  end

  def monster()
    onscreen = $controller.at(@x, @y)
    @y < 22 and @y > 0 and Tile.monster?(onscreen) ? onscreen : nil
  end

  def scenery?()
    Tile.scenery?(@scenery)
  end

  def walkable?()
    @y < 22 and @y > 0 and Tile.walkable?(@scenery)
  end

  def monster?()
    onscreen = $controller.at(@x, @y)
    Tile.monster?(onscreen) ? true : false
  end

  def walk_penalty()
    Tile.walk_penalty(@scenery)
  end

  def try_auto_explore_corridor()
    horiz = 0
    vert = 0
    $map.each_direction do |dx, dy|
      t = $map.at(x+dx, y+dy)
      next if t.scenery == nil or t.scenery == "\0"
      return false if t.scenery != "#"
      return false if dx != 0 and dy != 0
      horiz += 1 if dy == 0
      vert += 1 if dx == 0
    end

    return false unless horiz == 1 and vert == 1
    @explored = true
    return true
  end

  def try_auto_explore()
    return :already_explored if @explored
    return false if not walkable?
    return false if @unsure
    return try_auto_explore_corridor() if @scenery == "#"
    return false if @scenery == "]" or @scenery == "\0"

    $map.each_adjacent_tile_to(@x, @y) do |tile|
      return false if tile.scenery == "\0" or tile.scenery == "#" or tile.scenery == nil or tile.scenery == " "
    end

    @explored = true
    return true
  end

  def searches_left(type)
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

      if type == :sum
        searches_left += 12 - t.searched
      elsif type == :max
        searches_left = [searches_left, 12 - t.searched].max
      end
    end

    return searches_left
  end
end

