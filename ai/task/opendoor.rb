#!/usr/bin/ruby

class TaskOpenDoor
  def initialize()
  end

  def openable?(tile)
    case tile
    when "]"
      1
    else
      nil
    end
  end

  def run()
    move = next_move($hero.x, $hero.y)
    if move
      $stderr.puts "Opening toward #{move} from #{$hero.x}, #{$hero.y}"
      $controller.send("o" + move)
    end
    return move != nil
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
    each_adjacent do |dx, dy|
      if openable?($controller.at(x+dx,y+dy))
        return move_with_delta(dx, dy)
      end
    end

    return nil
  end
end
