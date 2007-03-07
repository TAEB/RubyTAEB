#!/usr/bin/ruby

# We use 2n and 2n+1 for n's children, so we can't have anything in @heap[0]
# (because 2*0 == 0, so 0 would be listed as 0's child)
# ... so, in summary, we use 1-based indexing.

# Most of this code is based on column 14 ("Heaps") of Programming Pearls.

class PriorityQueue
  def initialize()
    @heap = [0]
    @n = 0
  end

  def insert(val)
    @n += 1
    @heap[@n] = val
    _sift_up(@n)
    return val
  end

  def pop_min()
    return nil if @n == 0

    min = @heap[1]
    @heap[1] = @heap[@n]
    @heap.delete_at(@n)
    @n -= 1
    _sift_down(1)

    return min
  end

  def peek_min()
    return nil if @n == 0
    return @heap[1]
  end

  def all_values()
    return @heap[1..@n]
  end

  def size()
    return @n
  end

  def empty?()
    return @n == 0
  end

  def _sift_up(idx)

    # while we're not at the root and current node is smaller than its parent
    while idx > 1 && @heap[idx] < @heap[idx>>1]
      # swap!
      t = @heap[idx]
      @heap[idx] = @heap[idx>>1]
      idx >>= 1
      @heap[idx] = t
    end
  end

  def _sift_down(idx)

    # aka while we have children
    while (c = 2*idx) <= @n

      # Is our right child smaller than our left?
      if c+1 <= @n && @heap[c+1] < @heap[c]
        c += 1
      end

      # Heap condition restored, hurrah.
      break if @heap[idx] < @heap[c]

      # Swap this node with its (lesser) child.
      t = @heap[idx]
      @heap[idx] = @heap[c]
      @heap[c] = t

      idx = c
    end
  end
end

# This is given so we can fall back to it if the above implementation appears to fail.
# It's too simple to be wrong (famous last words? :)).
class PriorityQueueArray
  def initialize()
    @arr = []
  end

  def insert(val)
    @arr.push(val)
    @arr.sort!
    return val
  end

  def pop_min()
    return @arr.shift
  end

  def peek_min()
    return @arr[0]
  end

  def all_values()
    return @arr
  end

  def size()
    return @arr.size
  end

  def empty?()
    return @arr.size == 0
  end
end

if __FILE__ == $0
  require "assert.rb"

  pq = PriorityQueue.new()

  assert_eq("PQ initially empty 1/5", pq.empty?, true)
  assert_eq("PQ initially empty 2/5", pq.size, 0)
  assert_eq("PQ initially empty 3/5", pq.all_values.sort, [])
  assert_eq("PQ initially empty 4/5", pq.peek_min, nil)
  assert_eq("PQ initially empty 5/5", pq.pop_min, nil)

  pq.insert(3)
  assert_eq("PQ returns not empty after insertion.", pq.empty?, false)
  assert_eq("PQ returns size 1 after insertion.", pq.size, 1)
  assert_eq("PQ inserts a value correctly.", pq.all_values.sort, [3])
  assert_eq("PQ peeks at the minimum value correctly.", pq.peek_min, 3)
  assert_eq("PQ removes the minimum value correctly 1/2", pq.pop_min, 3)
  assert_eq("PQ removes the minimum value correctly 2/2", pq.all_values.sort, [])

  pq.insert(4)
  pq.insert(2)
  assert_eq("PQ returns not empty after two insertions.", pq.empty?, false)
  assert_eq("PQ returns size 2 after two insertions.", pq.size, 2)
  assert_eq("PQ inserts multiple values correctly.", pq.all_values.sort, [2, 4])

  assert_eq("PQ peeks at the minimum value (of 2) correctly 1/2", pq.peek_min, 2)
  assert_eq("PQ removes the minimum value (of 2) correctly 1/4", pq.pop_min, 2)
  assert_eq("PQ returns not empty after two insertions then removal.", pq.empty?, false)
  assert_eq("PQ returns size 1 after two insertions then removal.", pq.size, 1)
  assert_eq("PQ removes the minimum value (of 2) correctly 2/4", pq.all_values.sort, [4])

  assert_eq("PQ peeks at the minimum value correctly 2/2", pq.peek_min, 4)
  assert_eq("PQ removes the minimum value correctly 3/4", pq.pop_min, 4)
  assert_eq("PQ removes the minimum value correctly 4/4", pq.all_values.sort, [])
  assert_eq("PQ returns empty after two insertions then two removals.", pq.empty?, true)
  assert_eq("PQ returns size 0 after two insertions then two removals.", pq.size, 0)

  # Begin building huge test case!
  # We take 1001 integers (half positive, half negative, one zero :))
  # shuffle them, add them to the priority queue, and then go wild.

  t = []
  (-500..500).each {|n| t.push(n) }

  class Array
    def shuffle!
      size.downto(1) {|n| push(delete_at(rand(n)))}
      self
    end
  end

  t.shuffle!
  t.each {|n| pq.insert(n) }
  t.sort!

  while t.size > 0
    min = t[0]

    # Comment out this first assertion if you're testing the heap versus array PQ
    # implementations. Ruby optimizes sorting a sorted list, which means, if you include
    # this first test, the array implementation will almost always be faster.
    assert_eq("Huge test 1/5", pq.all_values.sort, t)
    assert_eq("Huge test 2/5", pq.empty?, false)
    assert_eq("Huge test 3/5", pq.size, t.size)
    assert_eq("Huge test 4/5", pq.peek_min, min)
    assert_eq("Huge test 5/5", pq.pop_min, min)
    t.delete_at(0)
  end

  assert_eq("Post huge test 1/5", pq.all_values.sort, [])
  assert_eq("Post huge test 2/5", pq.empty?, true)
  assert_eq("Post huge test 3/5", pq.size, 0)
  assert_eq("Post huge test 4/5", pq.peek_min, nil)
  assert_eq("Post huge test 5/5", pq.pop_min, nil)

  print "unit test succeeded\n"
end

