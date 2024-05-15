require 'byebug'

mutex = Thread::Mutex.new
shared_resource = []

thread1 = Thread.new do
    print "switched to thread1\n\n"
    mutex.lock
    print "mutex locked in thread1! \n"

    loop do
        print "sleeping for 5s to allow another thread to be scheduled... \n\n"
        mutex.sleep(2) # acquired mutex lock sleeps for 2 seconds. During this 2 second-window this thread release the mutex lock and
                      # the thread scheduler schedules another thread to run, in this case thread2. During this window the mutex is not locked.
        
        print "back inside thread1!\n\n"
        print "mutex locked? #{mutex.locked?}"
        
        shared_resource << rand(0.1)
        p "shared resources -> #{shared_resource}"
    end

    puts 'do i ever get here?'
end

thread2 = Thread.new do
    print "switched to thread2\n\n"

    loop do
        print "loop inside thread2!\n\n"
        p "shared resources -> #{shared_resource}"
        
        # because the mutex is unlocked in a 2-second window, this thread can acquire the lock during this window and perform some task
        # to perform a task we check if indeed the mutex is unlocked and free to acquire. If so, this thread acquires the lock and performs
        # a task after which it releases the mutex lock by unlocking it. because this is inside a loop, it will lock and unlock until the 
        # 2-second window is up.
        if mutex.try_lock
            print "mutex locked in thread2! \n"
            shared_resource << 'hi'
            sleep 1
            mutex.unlock
            puts 'unlocked!!!'
        else
            # this branch here runs when the 2-second window is up and the mutex is locked once again. 
            # here the previous thread, thread1, acquires the lock again. This can be verified by calling mutex.owned? whcih should return false

            puts "mutex.owned? -> #{mutex.owned?}"
            puts "mutex.locked? -> #{mutex.locked?}"
            puts 'Try again in minute. Mutex seems to have been acquired by another thread'
           
            # we call Thread.pass to signal the thread scheduler/OS to schedule a different thread. this will switch excution back to thread1
            puts "signal thread scheduler to switch to thread1"
            Thread.pass
            puts "back in thread2!"
        end       
    end

end

puts 'before....'
[thread1, thread2].each(&:join)
puts 'after...'