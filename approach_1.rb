# Check for result in the main thread continously until background thread sets the result to the FutureResult
class FutureResult
  attr_accessor :pending, :result

  def initialize
    self.pending = true
  end

  def pending?
    pending
  end
end

future = FutureResult.new
lock = Monitor.new
background_thread_calls = 0
main_thread_calls = 0


Thread.new do
  i = 0
  loop do
    puts "Inside background thread"
    i = i +1
    if i == 10000
      lock.synchronize do
        future.result = "Success"
        future.pending = false
      end
    end
    background_thread_calls = background_thread_calls + 1
  end
end


while future.pending?
  puts "Not resolved"
  main_thread_calls = main_thread_calls + 1
end
puts "result #{future.result}"


# Con
# CPU utilised in the main thread even though results are not available.










