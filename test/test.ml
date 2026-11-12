let run_test_group name test_fn =
  try
    Printf.printf "\n=== %s ===\n" name;
    test_fn ();
    Printf.printf "✓ All tests in %s passed\n" name
  with
  | Failure msg ->
    Printf.eprintf "✗ FAILURE in %s: %s\n" name msg;
    exit 1
  | exn ->
    Printf.eprintf "✗ ERROR in %s: %s\n" name (Printexc.to_string exn);
    exit 1

let () =
  Printf.printf "========================================\n";
  Printf.printf "Eventually Package Test Suite\n";
  Printf.printf "========================================\n";

  run_test_group "Timer Module" Test_timer.timer_test;
  run_test_group "Eventually Core" Test_eventually.eventually_test;
  run_test_group "Supply Module" Test_supply.test;

  Printf.printf "\n========================================\n";
  Printf.printf "✓ All tests passed!\n";
  Printf.printf "========================================\n"
