type timer =
  | Zero
  | Incr of (unit -> timer)

let ticks_negative () = invalid_arg "number of ticks must be non-negative"

let zero = Zero

let rec incr_unsafe n t =
  match n with
  | 0 -> t
  | 1 -> Incr (fun () -> t)
  | _ -> let n' = n - 1 in Incr (fun () -> incr_unsafe n' t)

let incr n t =
  if n >= 0 then incr_unsafe n t
  else ticks_negative ()

let rec decr_unsafe n m t =
  match n, t with
  | 0, _ -> Ok t
  | _, Zero -> Error m
  | _, Incr s -> decr_unsafe (n - 1) (m + 1) (s ())

let decr n t =
  if n >= 0 then decr_unsafe n 0 t
  else ticks_negative ()

let rec min t1 t2 =
  match t1, t2 with
  | Zero, _ -> Zero
  | _, Zero -> Zero
  | Incr s1, Incr s2 -> Incr (fun () -> min (s1 ()) (s2 ()))

let rec max t1 t2 =
  match t1, t2 with
  | Zero, _ -> t2
  | _, Zero -> t1
  | Incr s1, Incr s2 -> Incr (fun () -> max (s1 ()) (s2 ()))

let rec forever =
  Incr (fun () -> forever)
