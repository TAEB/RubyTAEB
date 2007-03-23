#!/usr/bin/ruby
require 'ai/task/base.rb'

class TaskEat < BaseTask
  def should_run?()
    # do we want hungry here? that would make prayer not happen until we were
    # out of food...
    return false unless $controller.vt.row(23) =~ /(Weak|Fainting|Fainted)/
    return true
  end

  def run()
    $controller.send("e")

    while 1
      if $controller.vt.row(0) =~ /^You don't have anything to eat\./
        return false
      end

      # handle items on the ground
      if $controller.vt.row(0) =~ /^There (?:is|are) (.+) here; eat (?:it|one)\? \[ynq\] \(n\)/
        if safe_food?($1)
          $controller.send("y")
          return true
        end
        $controller.send("n")
        next
      end

      # handle items in inventory
      $controller.send("?")
      menu = nil
      begin
        menu = Menu.new()
        menu.single_select() do |food|
          safe_food?(food)
        end
        return true
      rescue RuntimeError => err
        if err.to_s == "I see no menu on the screen."
          # only one stack of food in inv, eat it if it's safe
          if $controller.vt.row(0) =~ /^(.) - (.+)--More-- *$/
            $controller.send(" ")
            if safe_food?($2)
              $controller.send($1)
              return true
            else
              $controller.send("\n")
              return false
            end
          end
          raise "E001: Did not match the expected eat-command regex"
        elsif err.to_s == "I didn't select an item from the single-select menu."
          menu.execute()
          return false
        else
          raise err
        end
      end
    end
  end
end
