#!/usr/bin/ruby
require 'interface/tile.rb'

$need_clear = false

class Map
  attr_accessor :updated_this_turn

  def initialize()
    @map = []
    @z = 1
    initialize_level(@z)
    @updated_this_turn = false
  end

  def initialize_level(z)
    @map[z] ||= Array.new(81) {|x| Array.new(25) {|y| Tile.new(z, x, y) }}
  end

  def Map.each_direction()
    for dx in [-1, 0, 1]
      for dy in [-1, 0, 1]
        yield dx, dy unless dx == 0 and dy == 0
      end
    end
  end

  def Map.each_adjacent_to(x, y)
    Map.each_direction {|dx, dy| yield x+dx, y+dy unless y+dy < 1 or y+dy > 22}
  end

  def each_adjacent_tile_to(x, y)
    Map.each_adjacent_to(x, y) {|x, y| yield @map[@z][x][y]}
  end

  def Map.each_adjacent()
    Map.each_adjacent_to($hero.x, $hero.y) {|x, y| yield x, y}
  end

  def each_adjacent_tile()
    Map.each_adjacent {|x, y| yield @map[@z][x][y]}
  end

  def Map.each_coord()
    0.upto(80) do |x|
      0.upto(24) do |y|
        yield x, y
      end
    end
  end

  def each_tile()
    Map.each_coord {|x, y| yield @map[@z][x][y]}
  end

  def Map.delta_with_move(move)
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

  def Map.move_with_delta(dx, dy)
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

  def Map.each_step_in_path(path, x0=$hero.x, y0=$hero.y)
    x, y = x0, y0

    path.each_byte do |dir|
      dx, dy = Map.delta_with_move(dir.chr)
      x += dx
      y += dy
      yield x, y
    end
    return [x, y]
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

      Map.each_direction do |dx, dy|
        next if visited[x+dx][y+dy]
        visited[x+dx][y+dy] = true
        next if not at(x+dx, y+dy).walkable?

        # handle not walking diagonally off/onto doors
        next if dx != 0 and dy != 0 and
          (at(x   , y   ).scenery == ',' or
           at(x+dx, y+dy).scenery == ',')

        queue.push([x+dx, y+dy, path + Map.move_with_delta(dx, dy)])
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

  def birdfly_path(x0, y0, x1, y1)
    dx = x1 - x0
    dy = y1 - y0
    path = ""

    while dx != 0 or dy != 0
      if dx > 4 and dy > 4
        dx -= 8
        dy -= 8
        path += "N"
      elsif dx > 4 and dy < 4
        dx -= 8
        dy += 8
        path += "U"
      elsif dx < 4 and dy > 4
        dx += 8
        dy -= 8
        path += "B"
      elsif dx < 4 and dy < 4
        dx += 8
        dy += 8
        path += "Y"
      elsif dx < 4
        dx += 8
        path += "H"
      elsif dx > 4
        dx -= 8
        path += "L"
      elsif dy < 4
        dy += 8
        path += "J"
      elsif dy > 4
        dy -= 8
        path += "K"
      elsif dx > 0 and dy > 0
        dx -= 1
        dy -= 1
        path += "n"
      elsif dx > 0 and dy < 0
        dx -= 1
        dy += 1
        path += "u"
      elsif dx < 0 and dy > 0
        dx += 1
        dy -= 1
        path += "b"
      elsif dx < 0 and dy < 0
        dx += 1
        dy += 1
        path += "y"
      elsif dx < 0
        dx += 1
        path += "h"
      elsif dx > 0
        dx -= 1
        path += "l"
      elsif dy < 0
        dy += 1
        path += "j"
      elsif dy > 0
        dy -= 1
        path += "k"
      end
    end

    return path
  end

  def display()
    herox = $controller.vt.x
    heroy = $controller.vt.y

    if $need_clear
      $need_clear = false
      print "\e[H\e[2J"
    end

    return $controller.vt.display_gen do |x, y|
      next $controller.vt.at(x, y) if y < 1 or y > 21
      color = ""
      end_color = ""

      begin
        tile = @map[@z][x][y]
        char = tile.scenery
        if tile.debug_color
          color = tile.debug_color
          end_color = "\e[0m"
        elsif tile.unsure
          color = "\e[1;31m"
          end_color = "\e[0m"
          char = $controller.vt.at(x, y)
        elsif tile.stepped_on > 0
          color = "\e[1;32m"
          end_color = "\e[0m"
        elsif tile.explored
          color = "\e[0;32m"
          end_color = "\e[0m"
        elsif tile.searched >= 12
          color = "\e[0;36m"
          end_color = "\e[0m"
        end

        char = '@' if herox == x and heroy == y
        color + char + end_color
      rescue
        " "
      end
    end
  end

  def update()
    if @updated_this_turn == 1
      @updated_this_turn == true
    else
      @updated_this_turn = false
    end

    $controller.vt.row(23) =~ /^ *Dlvl:(\d+)/ or raise "Unable to check dungeon level -- row(23) = #{$controller.vt.row(23)}"

    if @z != $1.to_i
      @z = $1.to_i
      initialize_level(@z)
      @updated_this_turn = true
      $need_clear = true
    end

    hx, hy = $hero.x, $hero.y
    @map[@z][hx][hy].stepped_on += 1
    @map[@z][hx][hy].explored = true

    Map.each_coord do |x, y|
      tile = @map[@z][x][y]
      onscreen = $controller.vt.at(x, y)
      unsure = false
      tile.monster = nil

      # assume the tile has limited walkability until otherwise noticed
      if not Tile.scenery?(onscreen)
        if @map[@z][x][y].scenery == "]"
          onscreen = ','
          unsure = true
        elsif @map[@z][x][y].scenery == nil or @map[@z][x][y].scenery == "\0"
          if onscreen != "\0"
            onscreen = ','
            unsure = true
          end
        else
          next
        end

        if Tile.monster?(onscreen)
          $controller.send(";" + Map.birdfly_path(hx, hy, x, y) + ".")
          top_row = $controller.vt.to_s
          $messages.clear_screen()
          if top_row =~ /\(((?:tame |peaceful )?(?:invisible )?)(.+?)(?: called (.+?))?(?: - [\w\s]+)?\)/
            attributes = $1
            species = $2
            id = $3 if $3
            id = species if $monsters.has_key?(species) # for uniques

            tame = attributes =~ /tame/
            peaceful = attributes =~ /peaceful/
            invisible = attributes =~ /invisible/

            unless id and $monsters.has_key?(id)
              monster = Monster.new(onscreen, species, x, y, @z)
              id = monster.id
            else
              monster = $monsters[id]
            end

            tile.monster = monster
            monster.tame = tame
            monster.peaceful = peaceful
            monster.invisible = invisible
          else
            raise "Unable to ; monster (glyph=#{onscreen}) at #{x}, #{y}"
          end
        end
      end

      if tile.scenery != onscreen
        tile.scenery = onscreen
        tile.unsure = unsure
        #tile.try_auto_explore
        @updated_this_turn = true
      end
      tile.try_auto_explore
    end
  end

  def at(x=$hero.x, y=$hero.y, z=@z)
    @map[z][x][y]
  end

  def at_delta(dx=0, dy=0, dz=0)
    at($hero.x+dx, $hero.y+dy, @z+dz)
  end

  def at_direction(dir)
    dx, dy = Map.delta_with_move(dir)
    at_delta(dx, dy)
  end
end


if __FILE__ == $0
  "hjklyubn".each_byte do |c|
    c = c.chr
    dx, dy = Map.delta_with_move(c)
    raise "#{c} != move_with_delta(delta_with_move(#{c}))" unless c == Map.move_with_delta(dx, dy)
  end
end

