(** The result of evaluating a function `f` at a point `x` will consist of
    the value `f(x)` and the derivative `f'(x)`. *)
type point =
  { value : float;
    derivative: float }

(** A function maps points [x : float] to those [eval f x : point]. *)
type func =
  | Eval of (float -> point)

(** Expose the evaluation map. *)
let eval (Eval f) = f

(** A designated error for floating-point comparison. *)
type tolerance =
  | Delta of float

(** Check that a float is within [d] of [0]. *)
let is_near_zero (Delta e) x = abs_float x < e

(** [sqrt_func c] is the function given by `f(x) = x^2 - c`,
    which will have `sqrt(c)` as a real root [c] is non-negative. *)
let sqrt_func c =
  Eval (fun x -> {
    value = x *. x -. c;
    derivative = 2.0 *. x })

let ( let* ) y f = Eventually.sequence y f
let ( and+ ) y z = Eventually.forkjoin y z

(** Execute
    {{:https://en.wikipedia.org/wiki/Newton%27s_method}Newton's method},
    with the initial value [x], to approximate a root of the function [f],
    so that the final vertical error is bounded by [e]. *)
let rec newtons e f x =
  let* () = Eventually.tick 1 in
  let { value = y; derivative = d } = eval f x in
  if is_near_zero e y then Eventually.return x
  else newtons e f (x -. (y /. d))

(** Execute [newtons] "in parallel" along a list of functions,
    returning a list of the root approximations. *)
let rec many_newtons e fs x =
  match fs with
  | [] -> Eventually.return []
  | f :: fs' ->
    let* x' = newtons e f x
    and+ xs' = many_newtons e fs' x in
    Eventually.return (x' :: xs')

(** We will accept approximations within a vertical error of [0.0001]. *)
let delta = Delta 0.0001

(** Take [1.0] as the initial guess for our square root approximation. *)
let init = 1.0

(** Prints an indication that the computation of the roots of [cs]
    resulted in a timeout. *)
let print_timeout cs =
  Printf.printf "At least one computation resulted in a timeout, out of:";
  ignore @@ List.map (fun c -> Printf.printf " %f" c) cs;
  Printf.printf "\nLikely because some root does not exist\n"

(** Prints an indication that the computations of the roots of [c]
    resulted in [root]. *)
let print_sqrt c root =
  Printf.printf "The square root of %f is approximately: %f\n" c root

(** Demonstrate computing the square roots of [cs],
    with a time budget of [limit] ticks. *)
let demonstrate_sqrts limit cs =
  let timer = Timer.incr limit Timer.zero in
  let fs = List.map sqrt_func cs in
  Printf.printf "Approximating each root for at most %d iterations...\n" limit;
  let maybe_roots = Eventually.run timer (many_newtons delta fs init) in
  match maybe_roots with
  | Eventually.Timeout -> print_timeout cs
  | Eventually.Success roots -> ignore @@ List.map2 print_sqrt cs roots

(** Main executable.
    Demonstrate the (attempted) computation
    of the square roots of -1, 1, 2, and 4. *)
let newton_main () =
  Printf.printf "========================================\n";
  Printf.printf "Newton's Method Demonstration\n";
  Printf.printf "========================================\n";
  demonstrate_sqrts 5 [ 1.0; 2.0; 4.0 ];
  print_endline "";
  demonstrate_sqrts 1000000 [ -1.0; 1.0 ]
