#!/usr/bin/ruby
require 'interface/tile.rb'

class Map
  attr_reader :updated_this_turn

  def initialize()
    @map = []
    @z = 1
    initialize_level(@z)
    @updated_this_turn = 0
  end

  def initialize_level(z)
    @map[z] ||= Array.new(81) {|x| Array.new(25) {|y| Tile.new(z, x, y) }}
  end

  def each_direction()
    for dx in [-1, 0, 1]
      for dy in [-1, 0, 1]
        yield dx, dy unless dx == 0 and dy == 0
      end
    end
  end

  def each_adjacent()
    each_direction {|dx, dy| yield $hero.x+dx, $hero.y+dy}
  end

  def each_adjacent_tile()
    each_adjacent {|x, y| yield @map[@z][x][y]}
  end

  def each_coord()
    0.upto(80) do |x|
      0.upto(24) do |y|
        yield x, y
      end
    end
  end

  def each_tile()
    each_coord {|x, y| yield @map[@z][x][y]}
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

  def path_to_best_match(x0, y0)
    queue = [[x0, y0, ""]]
    best_score = nil
    best_path = ""
    visited = Array.new(24) {|x| Array.new(55, false)}
    visited[x0][y0] = true

    while queue.size > 0
      x, y, path = shift

      score = yield(x, y, path)

      # shortcut to allow implementation of path_to_first_match in terms of this
      # method
      return path if score == true

      if best_score == nil or score > best_score
        best_score = score
        best_path = path
      end

      each_direction do |dx, dy|
        next if visited[x+dx][y+dy]
        visited[x+dx][y+dy] = true
        next if not walkable?(x+dx, y+dy)

        # handle not walking diagonally off/onto doors
        next if dx != 0 and dy != 0 and
          @map[@z][x   ][y   ].scenery == ',' or
          @map[@z][x+dx][y+dy].scenery == ','

        queue.push(x+dx, y+dy, path + move_with_delta(dx, dy))
      end
    end
    return best_path
  end

  def path_to_first_match(x0, y0)
    path_to_best_match(x0, y0) do |x, y, path|
      if yield(x, y, path)
        true
      else
        0
      end
    end
  end

  def travel(x0, y0, x1, y1)
    path_to_first_match(x0, y0) do |x, y, path|
      x == x1 and y == y1
    end
  end

  def update()
    $controller.vt.row(23) =~ /^ *Dlvl:(\d+)/ or raise "Unable to check dungeon level -- row(23) = #{$controller.vt.row(23)}"

    if @z != $1.to_i
      @z = $1.to_i
      initialize_level(@z)
      @updated_this_turn = 1
    end

    @map[@z][$hero.x][$hero.y].stepped_on += 1

    each_coord do |x, y|
      onscreen = $controller.vt.at(x, y)

      # assume the tile is very walkable until otherwise noticed
      if not Tile::scenery?(onscreen) and
         @map[@z][x][y].scenery == nil
        onscreen = ','
      end

      if @map[@z][x][y].scenery != onscreen
        @map[@z][x][y].scenery = onscreen
        @updated_this_turn = 1
      end
    end
  end

  def at(x, y, z=@z)
    @map[z][x][y]
  end

  def at_delta(dx=0, dy=0, dz=0)
    at($hero.x+dx, $hero.y+dy, @z+dz)
  end
end

