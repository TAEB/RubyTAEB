#!/usr/bin/ruby

class Map
  def initialize()
    @map = Array.new(81) {|z| Array.new(24) {|x| Array.new(55, "\0")}}
    @z = 1
  end

  def descend
    @z += 1
  end

  def scenery?(tile)
    case tile
    when '.', ',', ']', '-', '|', '#', '}', '{', '<', '>',
      1
    else
      nil
    end
  end

  def update(x=nil, y=nil, tile=nil)
    if (x != nil && y != nil && tile != nil)
      @map[x][y][@z] = tile
      return
    end

    0.upto(80) do |x|
      0.upto(24) do |y|
        if scenery?($controller.vt.at(x, y))
          @map[x][y][@z] = $controller.vt.at(x, y)
        end
      end
    end
  end

  def at(x, y, z=@z)
    @map[x][y][z]
  end
end

