#!/usr/bin/ruby

class TaskFixHunger
  def initialize()
  end

  def hungry?()
    $controller.vt.to_s =~ /Hungry|Weak|Fainting/
  end

  def run()
    if hungry?
      $stderr.puts "Praying because we're hungry"
      $controller.send("#pray\n")
      return 1
    end
    return nil
  end
end

