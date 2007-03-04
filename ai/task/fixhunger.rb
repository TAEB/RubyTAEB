#!/usr/bin/ruby

class TaskFixHunger
  def initialize()
  end

  def fainting?()
    $controller.vt.to_s =~ /Fainting|Fainted/
  end

  def weak?()
    $controller.vt.to_s =~ /Weak|Fainting|Fainted/
  end

  def hungry?()
    $controller.vt.to_s =~ /Hungry|Weak|Fainting|Fainted/
  end

  def run()
    if weak?
      $stderr.puts "Praying because we're weak"
      $controller.send("#pray\n")
      return 1
    end
    return nil
  end
end

