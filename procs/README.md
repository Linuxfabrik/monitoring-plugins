Why does the check most of the time shows "1 running (ps)"?

This is due to the fact that the check calls `ps` with some parameters to fetch the current process list. In other words, `ps` is in state `R` ("running") while fetching the process list.  Like `top` we take this into account and do not ignore its own call.


Only zombies that last longer than 24 hours result in a WARN, otherwise you might get flapping results, for example on a heavy-duty Apache webserver.


PROCESS STATE CODES
       Here are the different values that the s, stat and state output specifiers (header "STAT" or "S") will
       display to describe the state of a process:


        procstate   shown as          meaning
        --------------------------------------------------------------------------------------------------
               D    uninterruptible   uninterruptible sleep (usually IO)
               I    sleeping          Idle kernel thread
               R    running           running or runnable (on run queue)
               S    sleeping          interruptible sleep (waiting for an event to complete)
               T    stopped           stopped by job control signal
               t    stopped           stopped by debugger during the tracing
               W    paging            paging (not valid since the 2.6.xx kernel)
               X    dead              dead (should never be seen)
               Z    zombies           defunct ("zombie") process, terminated but not reaped by its parent
