#!/usr/bin/ruby

def assert(msg)
  raise "Assertion failed: " + msg unless yield
end

def assert_true(msg, test)
  raise "Assertion failed: " + msg + "\nExpected a true value\n" unless test
end

def assert_false(msg, test)
  raise "Assertion failed: " + msg + "\nExpected a false value\n" if test
end

def assert_eq(msg, a, b)
  raise "Assertion failed: " + msg + "\nExpected <" + a.to_s + "> to equal <" + b.to_s + ">\n" unless a == b
end

def assert_ne(msg, a, b)
  raise "Assertion failed: " + msg + "\nExpected <" + a.to_s + "> to NOT equal <" + b.to_s + ">\n" if a == b
end

