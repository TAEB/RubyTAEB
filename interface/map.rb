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

  def each_tile()
    0.upto(80) do |x|
      0.upto(24) do |y|
        yield x, y
      end
    end
  end

  def move_with_delta(dx, dy)
    case dx
    when -1
      case dy
      when -1
        return 'y'
      when 0
        return 'h'
      when 1
        return 'b'
      end
    when 0
      case dy
      when -1
        return 'k'
      when 1
        return 'j'
      end
    when 1
      case dy
      when -1
        return 'u'
      when 0
        return 'l'
      when 1
        return 'n'
      end
    end

    raise "Argument out of range in move_with_delta("+dx.to_s+","+dy.to_s+")"
  end

  def travel(x0, y0, x1, y1)
    queue = [[x0, y0, ""]]
    visited = Array.new(24) {|x| Array.new(55, false)}
    visited[x0][y0] = true

    while queue.size > 0
      x, y, path = shift
      if x == x1 and y == y1
        return path
      end
      each_adjacent do |dx, dy|
        next if visited[x+dx][y+dy]
        visited[x+dx][y+dy] = true
        next if not walkable?(x+dx, y+dy)
        queue.push(x+dx, y+dy, path + move_with_delta(dx, dy))
      end
    end
    return nil
  end

  def update()
    each_tile do |x, y|
      onscreen = $controller.vt.at(x, y)

      # assume the tile is very walkable until otherwise noticed
      if not Tile.scenery?(onscreen) and @map[x][y][@z].scenery = nil
        onscreen = '.'
      end

      if @map[x][y][@z].scenery != onscreen
        @map[x][y][@z].scenery = onscreen
        @updated_this_turn = 1
      end
    end
  end

  def at(x, y, z=@z)
    @map[x][y][z]
  end
end

