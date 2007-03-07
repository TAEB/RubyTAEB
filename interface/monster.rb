#!/usr/bin/ruby

$monsters = {}

class Monster
  attr_accessor :peaceful, :tame, :invisible
  attr_reader :id, :glyph, :species, :x, :y, :z

  def initialize(glyph, species, x, y, z)
    @peaceful = false
    @tame = false
    @invisible = false

    @glyph = glyph
    @species = species
    @x = x
    @y = y
    @z = z
    @id = Monster.gen_id()

    $controller.send("C" + Map.birdfly_path() + ".")
    $controller.send(species + " " + @id + "\n")
    if $controller.vt.row(0) =~ /doesn't like being called names!/
      @id = @species
    end
    $messages.clear_screen()

    $monsters[@id] = self
  end

  def Monster.gen_id(prefix)
    id = prefix
    4.times { id += (rand(26)+'a'[0]).chr }
    $monsters.has_key?(id) ? Monster.gen_id(prefix) : id
  end
end

