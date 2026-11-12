let a_long_time = 1000000
let a_negative_time = -1

(** Raise an exception if [n <> m]. *)
let assert_int_eq n m =
  if n = m then ()
  else failwith @@ Printf.sprintf "Expected %d but got %d" n m

(** Raise an exception if [f ()] does {e not} raise [Invalid_argument]. *)
let assert_raises_invalid_argument f =
  try
    let _ = f () in
    failwith "Expected an `Invalid_argument` exception"
  with Invalid_argument _ -> ()
