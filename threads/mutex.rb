sum = 0
mutex = Thread::Mutex.new

threads = 10.times.map do |n|
    Thread.new(n) do
        100_000.times do
            mutex.lock
            new_value = sum + 1
            print "#{new_value}    " if new_value % 250_000 === 0 # spawns a separate thread that is blocking, waiting on I/0
            sum = new_value
            mutex.unlock
        end
    end
end

threads.each(&:join)
puts "\nsum = #{sum}"