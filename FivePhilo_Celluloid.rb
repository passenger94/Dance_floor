require "observer"

class Chopstick
  def initialize
    @mutex = Mutex.new
    @drawn = false
  end

  def take
    loop { break if @drawn }
#    sleep rand
    @mutex.lock
  end

  def drop
    @mutex.unlock

  rescue ThreadError
    puts "Trying to drop a chopstick not acquired"
  end

  def in_use?; @mutex.locked? end
  def drawn?; @drawn end
  def drawn=(bool); @drawn = bool end
end

class Table
attr_reader :chopsticks
  def initialize(num_seats)
    @chopsticks  = num_seats.times.map { Chopstick.new }
  end

  def left_chopstick_at(position)
    index = (position - 1) % @chopsticks.size
    @chopsticks[index]
  end

  def right_chopstick_at(position)
    index = position % @chopsticks.size
    @chopsticks[index]
  end

  def chopsticks_in_use
    @chopsticks.select( &:in_use? ).size
  end
end


require 'celluloid/current'

class Philosopher
  include Observable
  include Celluloid
  
  def initialize(name)
    @name = name
    @relax = 1
  end

  def dine(waiter, position)
    @waiter = waiter
    table = @waiter.table
    
    @left_chopstick  = table.left_chopstick_at(position)
    @right_chopstick = table.right_chopstick_at(position)
    @bowl = 5
    
    sleep rand
    think
  end

  def think
#    puts "#{@name} is thinking."
    changed
    notify_observers("think", @name)
    sleep(rand)
    sleep @relax
    
    if @bowl == 0
        @waiter.async.tuck(@name)
#        puts #{@name} is sleeping................"
        changed
        notify_observers("sleep", @name)
    else
        @waiter.async.request_to_eat(Actor.current)
    end
  end

  def eat
#    puts "#{@name} is eating."
    slowdown
    take_chopsticks
    
    @bowl -= 1
    sleep(rand)
    slowdown
    
    drop_chopsticks
    slowdown
    
    @waiter.async.done_eating(Actor.current)
    
    think
  end

  def take_chopsticks
    @left_chopstick.take
    @right_chopstick.take
    changed
    notify_observers("take", @left_chopstick, @right_chopstick)
  end

  def drop_chopsticks
    changed
    notify_observers("drop", @left_chopstick, @right_chopstick)
    @left_chopstick.drop
    @right_chopstick.drop
  end

  def finalize
    drop_chopsticks
  end
  
  def slowdown
    sleep @relax
  end
end

class Waiter
  include Celluloid
  attr_reader :table
  
  def initialize(num_seats)
    @table = Table.new(num_seats)
    @eating = []
    @quieten = []
    @num_seats = num_seats
    
  end

  def request_to_eat(philosopher)
    return if @eating.include?(philosopher)

    @eating << philosopher
    philosopher.async.eat
  end

  def done_eating(philosopher)
    @eating.delete(philosopher)
    philosopher.slowdown
  end
  
  def tuck(philosopher)
    @quieten << philosopher
    if @quieten.size == @num_seats
        puts "...Shhhhhh ..."
        
#        Celluloid.shutdown
    end
  end
  
  
end


