#!/usr/bin/ruby

class TaskExplore
  def initialize()
    @map = Array.new(81) {|x| Array.new(24, "\0")}
    @stepped_on = Array.new(81) {|x| Array.new(24, 0)}
    @path = []
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
      true
    when ')', '[', '=', '"', '(', '%', '!', '?', '+', '/', '$', '*', '`'
      true
    else
      false
    end
  end

  def run()
    step_on($hero.x, $hero.y)
    move = next_move($hero.x, $hero.y)
    $stderr.puts "Making #{move} from #{$hero.x}, #{$hero.y}"
    tx = $hero.x, ty = $hero.y
    $controller.send(move)
    if tx == $hero.x && ty == $hero.y && move =~ /[yubn]/
      $map.update($hero.x, $hero.y, ',')
      return false
    end
    return true
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

  def bfs_for_zero_step(x, y)
    queue = [[x, y, []]]
    visited = Array.new(81) {|x| Array.new(24, false)}

    while queue.size > 0
      x, y, path = queue.shift
      if not stepped_on?(x, y)
        return path
      end
      visited[x][y] = true
      each_adjacent do |dx, dy|
        next if visited[x+dx][y+dy]
        if not walkable?($controller.at(x+dx, y+dy))
          visited[x+dx][y+dy] = true
          next
        end

        queue.push([x+dx, y+dy, path + [move_with_delta(dx, dy)]])
      end
    end

    return nil
  end

  def next_move(x, y)
    if @path.size > 0
      return @path.shift
    end

    path = bfs_for_zero_step(x, y)
    $stderr.puts "New path: " + path.to_s
    if path
      @path = path
      return @path.shift
    end
    return ['h', 'j', 'k', 'l', 'y', 'u', 'b', 'n'][rand(8)]
  end
end

