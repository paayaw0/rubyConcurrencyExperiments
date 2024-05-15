require 'byebug'

Thread.abort_on_exception = true # aborts the main thread from executing when a sub-thread raises an exception

4.times.map do |i|
    Thread.new(i) do
        raise 'Boom!' if i == 1
        print "#{i}\n"
    end
end

puts 'Waiting'
sleep 0.1
puts 'Done'