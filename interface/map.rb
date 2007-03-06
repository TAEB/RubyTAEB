#!/usr/bin/ruby
require 'interface/tile.rb'

class Map
  attr_reader :updated_this_turn

  def initialize()
    @map = []
    @z = 1
    initialize_level(@z)
    @updated_this_turn = false
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

  def each_adjacent_to(x, y)
    each_direction {|dx, dy| yield x+dx, y+dy unless y+dy < 1 or y+dy > 22}
  end

  def each_adjacent_tile_to(x, y)
    each_adjacent_to(x, y) {|x, y| yield @map[@z][x][y]}
  end

  def each_adjacent()
    each_adjacent_to($hero.x, $hero.y) {|x, y| yield x, y}
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

  def delta_with_move(move)
    case move
    when 'h'
      [-1, 0]
    when 'j'
      [0, 1]
    when 'k'
      [0, -1]
    when 'l'
      [1, 0]
    when 'y'
      [-1, -1]
    when 'u'
      [1, -1]
    when 'b'
      [-1, 1]
    when 'n'
      [1, 1]
    else
      raise "Bad argument in delta_with_move(#{move})"
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

  def path_to_best_match(x0, y0)
    queue = [[x0, y0, ""]]
    visited = Array.new(81) {|x| Array.new(25, false)}
    visited[x0][y0] = true

    best_score = nil
    best_path = ""

    while queue.size > 0
      x, y, path = queue.shift
      score = yield x, y, path

      # shortcut to allow implementation of path_to_first_match in terms of this
      # method
      return path if score == true

      # if score is false, it's definitely not a valid destination, but it could
      # be a hop along the path to the real dest
      if score and (best_score == nil or score > best_score)
        best_score = score
        best_path = path
      end

      each_direction do |dx, dy|
        next if visited[x+dx][y+dy]
        visited[x+dx][y+dy] = true
        next if not at(x+dx, y+dy).walkable?

        # handle not walking diagonally off/onto doors
        next if dx != 0 and dy != 0 and
          (at(x   , y   ).scenery == ',' or
           at(x+dx, y+dy).scenery == ',')

        queue.push([x+dx, y+dy, path + move_with_delta(dx, dy)])
      end
    end
    return best_path
  end

  def path_to_first_match(x0, y0)
    path_to_best_match(x0, y0) do |x, y, path|
      if yield x, y, path
        true
      else
        false
      end
    end
  end

  def travel(x0, y0, x1, y1)
    path_to_first_match(x0, y0) do |x, y, path|
      x == x1 and y == y1
    end
  end

  def update()
    @updated_this_turn = false

    $controller.vt.row(23) =~ /^ *Dlvl:(\d+)/ or raise "Unable to check dungeon level -- row(23) = #{$controller.vt.row(23)}"

    if @z != $1.to_i
      @z = $1.to_i
      initialize_level(@z)
      @updated_this_turn = true
    end

    @map[@z][$hero.x][$hero.y].stepped_on += 1
    @map[@z][$hero.x][$hero.y].explored = true

    each_coord do |x, y|
      onscreen = $controller.vt.at(x, y)
      unsure = false

      # assume the tile has limited walkability until otherwise noticed
      if not Tile.scenery?(onscreen)
        if @map[@z][x][y].scenery == nil
          if onscreen != "\0"
            onscreen = ','
            unsure = true
          end
        else
          next
        end
      end

      if @map[@z][x][y].scenery != onscreen
        @map[@z][x][y].scenery = onscreen
        @map[@z][x][y].unsure = unsure
        @map[@z][x][y].try_auto_explore
        @updated_this_turn = true
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


if __FILE__ == $0
  map = Map.new()
  "hjklyubn".each_byte do |c|
    c = c.chr
    dx, dy = map.delta_with_move(c)
    raise "#{c} != move_with_delta(delta_with_move(#{c}))" unless c == map.move_with_delta(dx, dy)
  end
end

