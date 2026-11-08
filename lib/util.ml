(** Raises [Invalid_argument] if [n] is negative. *)
let assert_ticks_nonnegative n =
  if n >= 0 then ()
  else invalid_arg "Number of ticks must be non-negative"
