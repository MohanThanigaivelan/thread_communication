

# Waiting for required future result pushed to the output queue
class FutureResult
  attr_accessor :result , :pending, :adapter

  def initialize(adapter)
    @adapter = adapter
    @pending = true
  end

  def result
    unless pending
      return @result
    end

    @adapter.process_result(self)

    @result
  end

  def assign_result(result)
    @pending = false
    @result  = result
  end
end

class PostgresPipeline
  def initialize
    @queue = Queue.new
    @lock = Monitor.new
  end

  def set_future_and_start_thread(futures)
    @piped_results = futures
    bg_fetch_result
  end

  def bg_fetch_result
    Thread.new do
      i = 0
      loop do
        i = i + 1
        sleep(3)
        @lock.synchronize do
          future = @piped_results.shift
          future.assign_result("Result #{i}")
          @queue.push(future)
        end
      end
    end
  end

  def process_result(req_future)
    loop do
      future = @queue.pop
      if req_future == future
        break
      end
    end
  end
end

adapter = PostgresPipeline.new
f1 = FutureResult.new(adapter)
f2 = FutureResult.new(adapter)
f3 = FutureResult.new(adapter)
f4 = FutureResult.new(adapter)
f5 = FutureResult.new(adapter)
futures = [f1, f2, f3, f4, f5]
adapter.set_future_and_start_thread(futures)


puts f2.result

# When is output queue being cleared ?
# Not Using queue to the fullest

