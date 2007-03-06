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
    Tile.monster?(onscreen) ? onscreen : nil
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

  def try_auto_explore()
    return :already_explored if @explored
    return false if not walkable?
    return false if @unsure
    return false if @scenery == "]" or @scenery == "#" or @scenery == "\0"

    $map.each_adjacent_tile_to(@x, @y) do |tile|
      return false if tile.scenery == "\0" or tile.scenery == "#" or tile.scenery == nil or tile.scenery == " "
    end

    @explored = true
    return true
  end
end

