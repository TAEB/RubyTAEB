#!/usr/bin/ruby

class Map
  attr_reader :updated_this_turn

  def initialize()
    @map = []
    @z = 1
    initialize_level(@z)
    @updated_this_turn = 0
  end

  def initialize_level(z)
    @map[z] = Array.new(24) {|x| Array.new(55) {|y| Tile.new() }}
  end

  def each_adjacent()
    for dx in [-1, 0, 1]
      for dy in [-1, 0, 1]
        yield dx, dy unless dx == 0 and dy == 0
      end
    end
  end

  def travel(x0, y0, x1, y1)
    queue = [[x0, y0, []]]
    visited = Array.new(81) {|z| Array.new(24) {|x| Array.new(55, false)}}
    visited[x0][y0] = true

    while queue.size > 0
      x, y, path = shift
      if x == x1 and y == y1
        return path
      end
      each_adjacent do |dx, dy|
      end
    end
  end

  def update(x=nil, y=nil, tile=nil)
    @updated_this_turn = 0
    $controller.vt.to_s =~ /Dlvl:(\d+)/ or raise "Unable to check dungeon level"
    @z = $1.to_i
    if (x != nil && y != nil && tile != nil)
      if @map[x][y][@z] != tile
        @updated_this_turn = 1
      end
      @map[x][y][@z] = tile
      return
    end

    0.upto(80) do |x|
      0.upto(24) do |y|
        if scenery?($controller.vt.at(x, y))
          if @map[x][y][@z] != $controller.vt.at(x, y)
            @updated_this_turn = 1
          end
          @map[x][y][@z] = $controller.vt.at(x, y)
        end
      end
    end
  end

  def at(x, y, z=@z)
    @map[x][y][z]
  end
end

