#!/usr/bin/ruby

class Menu
  def initialize()
    0.upto(24) do |y|
      if $controller.vt.row(y) =~ /^(.*)\((end|1 of (\d+))\) *$/
        @y = y
        @x = $1.length
        @pages = $2 == 'end' ? 1 : $3.to_i
        @page = 1
        return
      end
    end
    raise "I see no menu on the screen."
  end

  def each_item()
    while 1
      0.upto(24) do |y|
        item = $controller.vt.to_eol(@x, y)
        break if item =~ /^\(end|\d+ of \d+\) *$/
        yield item
      end
      break if @page == @pages
      $controller.send(" ")
      @page += 1
    end
    $controller.send("^")
    @page = 1
  end

  def finish()
    $controller.send("\n")
  end

  def toggle_each
    each_item do |item|
      next unless item =~ /^(.) ([-+]) (.+)$/ # skip over headings
      selector, on, item = $1, $2 == '+', $3
      if yield selector, item, on
        $controller.send(selector)
      end
    end
  end

  def select_each
    each_item do |item|
      next unless item =~ /^(.) - (.+)$/ # skip over headings, selected items
      selector, item = $1, $2
      if yield selector, item, false
        $controller.send(selector)
      end
    end
  end

  def unselect_each
    each_item do |item|
      next unless item =~ /^(.) \+ (.+)$/ # skip over headings, unselected items
      selector, item = $1, $2
      if yield selector, item, true
        $controller.send(selector)
      end
    end
  end

  def single_select
    each_item do |item|
      next unless item =~ /^(.) - (.+)$/ # skip over headings
      selector, item = $1, $2
      if yield selector, item
        $controller.send(selector)
        return
      end
    end

    raise "I didn't select an item from the single-select menu."
  end

  def toggle_glyphs(*glyphs)
    glyphs.each {|glyph| $controller.send(glyph)}
  end
end

