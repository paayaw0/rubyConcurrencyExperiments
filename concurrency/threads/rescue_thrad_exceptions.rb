require 'byebug'

threads = 4.times.map do |i|
    Thread.new(i) do
        raise 'BOOM!' if i == 1
        print "#{i}\n"
    end
end

threads.each do |t|
    t.join
rescue RuntimeError => e
    puts "Failed: #{e.message}"
end

puts 'Done'
