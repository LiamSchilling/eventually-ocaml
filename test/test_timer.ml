open Util

(** Raise an exception if [t] does not have exactly [n] ticks left. *)
let assert_timer_value n t =
  match Timer.decr (n + 1) t with
  | Ok _ -> failwith "Timer value greater than expected"
  | Error m -> if n = m then () else failwith "Timer value less than expected"

(** Raise an exception if [y] is not [Ok t]
    where [t] has exactly [n] ticks left. *)
let assert_result_value n y =
  match y with
  | Ok t -> assert_timer_value n t
  | Error _ -> failwith "Timer value less than expected"

(** Raise an exception if [t] has fewer than [a_long_time] ticks left. *)
let assert_timer_infinite t =
  match Timer.decr a_long_time t with
  | Ok _ -> ()
  | Error _ -> failwith "Expected timer value to be infinite"

let timer_test () =
  let t0 = Timer.zero in
  let t1 = Timer.incr 1 Timer.zero in
  let t2 = Timer.incr 2 Timer.zero in
  let tw = Timer.forever in

  assert_timer_value 0 t0;
  assert_timer_value 1 t1;
  assert_timer_value 2 t2;
  assert_timer_infinite tw;

  print_endline "✓ timer constructors tests passed";

  assert_timer_value 1 (Timer.incr 0 t1);
  assert_timer_value 5 (Timer.incr 3 t2);

  assert_result_value 1 (Timer.decr 0 t1);
  assert_result_value 0 (Timer.decr 2 t2);

  assert_timer_value 1 (Timer.min t1 t2);
  assert_timer_value 2 (Timer.max t1 t2);

  assert_timer_value 2 (Timer.min t2 tw);
  assert_timer_infinite (Timer.max t2 tw);

  print_endline "✓ timer operations tests passed";

  assert_raises_invalid_argument (fun () -> Timer.incr a_negative_time t0);
  assert_raises_invalid_argument (fun () -> Timer.incr a_negative_time t0);

  print_endline "✓ timer error handling tests passed"
