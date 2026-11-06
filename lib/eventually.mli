(** A value of type [timer] is one of
    - a natural number [until n], in which case the timer is called {e finite},
    - or the value [forever].

    We enforce that [until n] is equivalent to [until 0] for negative [n]. *)
type timer

(** The timer that finishes after [n] ticks. *)
val until : int -> timer

(** The timer that never finishes. *)
val forever : timer

(** A value of type ['a eventually] is a time-bounded computation
    that, when {!run} subject to a [timer], may either
    - return a value of type ['a],
    - or timeout.

    [y : 'a eventually] is said to {e converge} if
    [run t y] terminates for all {e finite} [t : timer]. *)
type 'a eventually

(** Advance the current [timer] by one unit,
    or timeout if the [timer] is already finished. *)
val tick : unit eventually

(** Monadic return/pure. *)
val return : 'a -> 'a eventually

(** Functorial map. *)
val map : ('a -> 'b) -> 'a eventually -> 'b eventually

(** Monadic bind. *)
val bind : 'a eventually -> ('a -> 'b eventually) -> 'b eventually

(** Run the computation, subject to a [timer]. Returns
    - [None] on timeout,
    - and [Some x] otherwise. *)
val run : timer -> 'a eventually -> 'a option

(** Should be raised if [run forever y] returns [None], which is impossible. *)
exception ForeverTimesout
