#!/usr/bin/ruby

class TaskExplore
  def initialize()
    @map = Array.new(81) {|x| Array.new(24, "\0")}
    @stepped_on = Array.new(81) {|x| Array.new(24, 0)}
  end

  def stepped_on?(x, y)
    @stepped_on[x][y] > 0
  end

  def step_times(x, y)
    @stepped_on[x][y]
  end

  def step_on(x, y)
    @stepped_on[x][y] += 1
  end

  def walkable?(tile)
    case tile
    when '.', ',', '#', '{', '_', '<', '>'
      1
    when ')', '[', '=', '"', '(', '%', '!', '?', '+', '/', '$', '*', '`'
      1
    else
      nil
    end
  end

  def run()
    step_on($hero.x, $hero.y)
    move = next_move($hero.x, $hero.y)
    $stderr.puts "Making #{move} from #{$hero.x}, #{$hero.y}"
    $controller.send(move)
    return 1
  end

  def move_with_delta(dx, dy)
    case dx
    when -1
      case dy
      when -1
        'y'
      when 0
        'h'
      when 1
        'b'
      else
        throw "unacceptable dy: #{dy}"
      end
    when 0
      case dy
      when -1
        'k'
      when 1
        'j'
      else
        throw "unacceptable dy: #{dy}"
      end
    when 1
      case dy
      when -1
        'u'
      when 0
        'l'
      when 1
        'n'
      else
        throw "unacceptable dy: #{dy}"
      end
    else
      throw "unacceptable dx: #{dx}"
    end
  end

  def each_adjacent()
    for dx in [-1, 0, 1]
      for dy in [-1, 0, 1]
        yield dx, dy unless dx == 0 and dy == 0
      end
    end
  end

  def next_move(x, y)
    best_val = nil
    best = []

    each_adjacent do |dx, dy|
      if (best_val == nil or step_times(x+dx,y+dy) <= best_val) and
          walkable?($controller.at(x+dx,y+dy))

            # can't walk diagonally off or onto a door
            if ($map.at(x, y) == ',' || $map.at(x+dx, y+dy) == ',') and
               dx != 0 and dy != 0
                 next
            end
            if step_times(x+dx, y+dy) > best_val
              best = []
            best_val = step_times(x+dx, y+dy)
            if step_times(x+dx, y+dy) == best_val
              best.push(move_with_delta(dx, dy))
      end
    end

    if best == []
      raise "I have nowhere to go! Ack!"
    end
    best[rand(best.size)]
  end
end

