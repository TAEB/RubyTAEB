#!/usr/bin/ruby

class Tile
  attr_accessor :scenery, :stepped_on
  attr_reader :x, :y, :z

  def initialize(z, x, y)
    @scenery = nil
    @items = nil
    @monster = nil
    @stepped_on = 0

    @z = z
    @x = x
    @y = y
  end

  def Tile.scenery?(glyph)
    case glyph
    when ".", "#", ",", "]", ">", "<", "{", "_", "\\", "^"
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

  def scenery?()
    Tile.scenery?(@scenery)
  end

  def walkable?()
    Tile.walkable?(@scenery)
  end

  def walk_penalty()
    Tile.walk_penalty(@scenery)
  end
end

