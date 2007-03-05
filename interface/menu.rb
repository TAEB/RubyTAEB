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

  def foreach_item()
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

  def execute()
    $controller.send("\n")
  end

  def toggle_all_matches(regex)
    foreach_item do |item|
      next unless item =~ /^(.) [-+] / # skip over headings, etc
      selector = $1
      if item =~ regex
        $controller.send(selector)
      end
    end
  end

  def select_all_matches(regex)
    foreach_item do |item|
      next unless item =~ /^(.) - / # skip over headings, selected items
      selector = $1
      if item =~ regex
        $controller.send(selector)
      end
    end
  end

  def unselect_all_matches(regex)
    foreach_item do |item|
      next unless item =~ /^(.) \+ / # skip over headings, unselected items
      selector = $1
      if item =~ regex
        $controller.send(selector)
      end
    end
  end

  def single_select(regex)
    selected = false

    foreach_item do |item|
      next unless item =~ /^(.) - / # skip over headings
      selector = $1
      if item =~ regex
        $controller.send(selector)
        selected = true
        break
      end
    end

    raise "I didn't select an item from the single-select menu." unless selected
  end

  def toggle_glyphs(*glyphs)
    glyphs.each {|glyph| $controller.send(glyph)}
  end
end

