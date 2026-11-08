(** A value of type [timer] is one of
    - a natural number [incr n zero],
      in which case the timer is called {e finite},
    - or the value [forever],
      in which case the timer is called {e infinite}.
    
    The interface exposes methods for constructing timers
    and observing their behavior over finite intervals.
    By design, it is not possible to observe that a timer is infinite. *)
type timer

(** A finished timer. *)
val zero : timer

(** Increment the number of ticks left by [n], and return the result.

    Raises [Invalid_argument] if [n] is negative. *)
val incr : int -> timer -> timer

(** Decrement the number of ticks left by [n]. Returns
    - [Error m] if the timer has [m] ticks left and [m < n],
    - and otherwise [Ok t] where [t] is the new timer.
    
    Raises [Invalid_argument] if [n] is negative.*)
val decr : int -> timer -> (timer, int) result

(** Returns the timer with the fewest ticks left. *)
val min : timer -> timer -> timer

(** Returns the timer with the most ticks left. *)
val max : timer -> timer -> timer

(** The timer that never finishes. *)
val forever : timer
