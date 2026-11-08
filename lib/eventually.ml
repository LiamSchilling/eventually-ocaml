open Util

type 'a now =
  | Timeout
  | Success of 'a

let ( let* ) y f =
  match y with
  | Timeout -> Timeout
  | Success x -> f x

type 'a eventually =
  | Eventually of (Timer.timer -> ('a * Timer.timer) now)

let unbox (Eventually f) = f

let tick n =
  assert_ticks_nonnegative n;
  Eventually (fun t1 ->
    match Timer.decr n t1 with
    | Ok t2 -> Success ((), t2)
    | Error _ -> Timeout)

let return x =
  Eventually (fun t -> Success (x, t))

let sequence y f =
  Eventually (fun t1 ->
    let* (x, t2) = unbox y t1 in
    unbox (f x) t2)

let forkjoin y z =
  Eventually (fun t1 ->
    let* (x, t2) = unbox y t1 in
    let* (w, t3) = unbox z t1 in
    Success ((x, w), Timer.min t2 t3))

let run t y =
  let* (x, _) = unbox y t in Success x

exception ForeverTimesout
