open Util

(** Raises an exception if [y] is not [Success n]. *)
let assert_result_value n y =
  match y with
  | Eventually.Timeout -> failwith "Unexpected timeout"
  | Eventually.Success m -> assert_int_eq n m

(** Raises an exception if [y] is not [Timeout]. *)
let assert_result_timeout y =
  match y with
  | Eventually.Timeout -> ()
  | Eventually.Success _ -> failwith "Expected timeout"

let eventually_test () =
  let t0 = Timer.zero in
  let t1 = Timer.incr 1 t0 in
  let t2 = Timer.incr 2 t0 in
  let t3 = Timer.incr 3 t0 in
  let tick0 = Eventually.tick 0 in
  let tick1 = Eventually.tick 1 in
  let tick2 = Eventually.tick 2 in
  let pure = Eventually.return 42 in

  let par =
    Eventually.sequence (Eventually.forkjoin tick1 tick2) (fun ((), ()) -> pure) in

  let seq =
    Eventually.sequence tick0 (fun () ->
      Eventually.sequence tick1 (fun () ->
        Eventually.sequence par (fun _ -> pure))) in

  print_endline "✓ eventually constructors tests passed";
  
  assert_result_value 42 (Eventually.run t0 pure);

  assert_result_value 42 (Eventually.run t3 seq);
  assert_result_timeout (Eventually.run t2 seq);

  assert_result_value 42 (Eventually.run t2 par);
  assert_result_timeout (Eventually.run t1 par);

  print_endline "✓ eventually control flow tests passed";

  assert_raises_invalid_argument (fun () -> Eventually.tick (-1));

  print_endline "✓ eventually error handling tests passed"
