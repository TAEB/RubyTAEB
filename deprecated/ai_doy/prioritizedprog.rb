#!/usr/bin/ruby
require 'ai/prog.rb'

class PrioritizedProg
  attr_accessor :priority, :prog
  def initialize(priority, prog)
    @priority = priority
    @prog = prog
  end
end
