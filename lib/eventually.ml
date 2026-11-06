type timer =
  | Zero
  | Incr of (unit -> timer)

let rec until n =
  if n <= 0 then Zero else Incr (fun () -> until (n - 1))

let rec forever =
  Incr (fun () -> forever)

type 'a eventually =
  | Eventually of (timer -> ('a * timer) option)

let unbox (Eventually x) = x

let tick =
  Eventually (function
  | Zero -> None
  | Incr s -> Some ((), s ()))

let return x =
  Eventually (fun t -> Some (x, t))

let ( let+ ) y f = Option.map f y
let ( let* ) y f = Option.bind y f

let map f y =
  Eventually (fun t1 ->
    let+ (x, t2) = unbox y t1 in
    (f x, t2))

let bind y f =
  Eventually (fun t1 ->
    let* (x, t2) = unbox y t1 in
    unbox (f x) t2)

let run t y =
  let+ (x, _) = unbox y t in x

exception ForeverTimesout
