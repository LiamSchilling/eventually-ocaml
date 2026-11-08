(** A value of type ['a eventually] is a time-bounded computation
    that, when [run] subject to a timer, may either
    - return a value of type ['a],
    - or timeout.

    [y : 'a eventually] is said to {e converge} if
    [run t y] terminates for all finite timers [t]. *)
type 'a eventually

(** The result of running a time-bounded computation, which is either
    - a timeout [Timeout],
    - or a returned value [Success x]. *)
type 'a now =
  | Timeout
  | Success of 'a

(** Advance the current timer by [n] ticks,
    or timeout if the timer is already finished.

    Raises [Invalid_argument] if [n] is negative. *)
val tick : int -> unit eventually

(** Return a pure value. *)
val return : 'a -> 'a eventually

(** Sequence two computations, binding a value dependency between them. *)
val sequence : 'a eventually -> ('a -> 'b eventually) -> 'b eventually

(** Simulate the parallel execution of two computations. *)
val forkjoin : 'a eventually -> 'b eventually -> ('a * 'b) eventually

(** Run the computation, subject to a timer. Returns
    - [Timeout] on timeout,
    - and [Success x] otherwise. *)
val run : Timer.timer -> 'a eventually -> 'a now

(** Should be raised if [run Timer.forever y] returns [Timeout],
    which is impossible. *)
exception ForeverTimesout
