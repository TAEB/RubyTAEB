#!/usr/bin/ruby

class VT
  attr_reader :x, :y

  def initialize(width, height)
    @width = width
    @height = height
    @x = 0
    @y = 0
    @mode = :text
    set_screen()
  end

  def set_screen
    @screen = Array.new(@width+1) {|x| Array.new(@height+1, "\0")}
  end

  def display()
    print "\e[H\e[2J"
    0.upto(@height) do |y|
      0.upto(@width) do |x|
        print "\e[#{y+1};#{x+1}H" + @screen[x][y]
      end
    end
    print "\e[#{@y+1};#{@x+1}H"
    $stdout.flush
  end

  def to_s
    output = ''
    0.upto(@height) do |y|
      0.upto(@width) do |x|
        output += @screen[x][y] == "\0" ? ' ' : @screen[x][y]
      end
    end
    output
  end

  def parse(input)
    input.each_byte do |c|
      chr = c.chr

      case @mode
      when :text
        if chr == "\e"
          @mode = :esc_need_bracket
        elsif c == 8
          @x -= 1
        elsif c == 10
          @y += 1
        elsif c == 13
          #@y += 1
          @x = 0
        elsif c > 0 && c < 32
          raise "Unprintable character ##{c}"
        else
          if @x < 0
            @x = 0
          end
          if @y < 0
            @y = 0
          end
          #if @y > @height
          #  @y -= 1
          #  @x = @width if @x > @width
          #end
          #if @x > @width
          #  @y++
          #  @x = 0
          #end
          @screen[@x][@y] = chr
          @x += 1
        end
      when :esc_need_bracket
        if chr == "["
          @mode = :esc
          @num1 = nil
          @num2 = nil
        elsif chr == "("
          @mode = :text # enable alternate charset
        elsif chr == ")"
          @mode = :text # disable alternate charset
        elsif chr == ">"
          @mode = :text # dunno
        elsif chr == "M"
          @mode = :text
          @y -= 1
        elsif chr >= "0" && chr <= "9"
          @mode = :text
        else
          raise "\e[2JUnknown escape sequence '#{chr}' == chr(#{c})"
        end
      when :esc
        case chr
        when "0".."9"
          if @num2 == nil
            if @num1 == nil
              @num1 = c.chr.to_i
            else
              @num1 = @num1 * 10 + c.chr.to_i
            end
          else
            if @num2 == -1
              @num2 = c.chr.to_i
            else
              @num2 = @num2 * 10 + c.chr.to_i
            end
          end
        when ";"
          @num2 = -1
        when "m"
          @mode = :text
          # TODO: set some sort of color field
        when "H"
          @mode = :text
          @num1 = 1 if @num1 == nil
          @num2 = 1 if @num2 == nil
          @y = @num1 - 1
          @x = @num2 - 1
        when "J"
          @mode = :text
          @num1 = 0 if @num1 == nil
          if @num1 == 2
            set_screen()
            @x = @y = 0
          elsif @num1 == 0
            @y.upto(@height) do |y|
              @x.upto(@width) do |x|
                @screen[x][y] = "\0"
              end
            end
          elsif @num1 == 1
            0.upto(@y) do |y|
              0.upto(@x) do |x|
                @screen[x][y] = "\0"
              end
            end
          end
        when "K"
          @mode = :text
          if @num1 == 0 || @num1 == nil
            @x.upto(@width) {|x| @screen[x][@y] = "\0"}
          elsif @num1 == 1
            0.upto(@x) {|x| @screen[x][@y] = "\0"}
          elsif @num1 == 2
            0.upto(@width) {|x| @screen[x][@y] = "\0"}
          end
        when "A"
          @mode = :text
          @num1 = 1 if @num1 == nil
          @y -= @num1
        when "B"
          @mode = :text
          @num1 = 1 if @num1 == nil
          @y += @num1
        when "C"
          @mode = :text
          @num1 = 1 if @num1 == nil
          @x += @num1
        when "D"
          @mode = :text
          @num1 = 1 if @num1 == nil
          @x -= @num1
        when "?"
          @mode = :text
        when "l"
          @mode = :text
          # disable line wrap
        else
          raise "Unhandled escape sequence marker <#{chr}> = chr(#{c})."
        end
      end
    end
  end
end

if __FILE__ == $0
  vt = VT.new(80, 24)

  if (ARGV[0])
    filename = ARGV[0]
    raise "usage: $0 ttyrec" if filename == nil
    ttyrec = File.new(filename, "r")

    prev = nil
    frame = 0
    while 1
      frame += 1
      header = ttyrec.read(12)
      exit if header == nil
      sec, usec, len = header.unpack("VVV")
      data = ttyrec.read(len)
      exit if header == nil

      time = sec + usec /1000000.0
      if prev != nil
        diff = time - prev
        diff = 3 if diff > 3
        sleep(diff)# if frame > 440
      end
      prev = time

      vt.parse(data)
      vt.display()# if frame > 440
    end
  else
    vt.parse("foo")
    raise "can't handle plaintext" unless vt.to_s =~ /^foo +$/

    vt.parse("bar")
    raise "can't handle multiple plaintext" unless vt.to_s =~ /^foobar +$/

    vt.parse("\e[0;31mbaz")
    raise "can't strip out color" unless vt.to_s =~ /^foobarbaz +$/

    vt.parse("qu\e[")
    vt.parse("0mux")
    raise "can't strip out color across multiple parses" unless vt.to_s =~ /^foobarbazquux +$/

    vt.parse("\e[2J")
    raise "can't handle \\e[2J" unless vt.to_s =~ /^ +$/

    vt.parse("\e[Hfoo")
    raise "can't handle \\e[H" unless vt.to_s =~ /^foo +$/

    vt.parse("\e[2J\e[2Hfoo")
    raise "can't handle \\e[2H" unless vt.to_s =~ /^ {81}foo +$/

    vt.parse("\e[2J\e[1;2Hfoo")
    raise "can't handle \\e[1;2H" unless vt.to_s =~ /^ foo +$/

    vt.parse("\e[2J\e[Hfoo\e[1;2H\e[K")
    raise "can't handle \\e[K" unless vt.to_s =~ /^f +$/

    vt.parse("lol")
    raise "\\e[K changes cursor position" unless vt.to_s =~ /^flol +$/

    vt.parse("\e[1;3H\e[1K")
    raise "can't handle \\e[1K" unless vt.to_s =~ /^   l +$/

    vt.parse("quiz")
    raise "\\e[1K changes cursor position" unless vt.to_s =~ /^  quiz +$/

    vt.parse("\e[2K")
    raise "can't handle \\e[2K" unless vt.to_s =~ /^ +$/

    vt.parse("test")
    raise "\\e[2K changes cursor position" unless vt.to_s =~ /^      test +$/
  end
end

