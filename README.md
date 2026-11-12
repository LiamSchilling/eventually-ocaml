[![OCaml-CI Build Status](https://img.shields.io/endpoint?url=https://ocaml.ci.dev/badge/LiamSchilling/eventually-ocaml/main&logo=ocaml)](https://ocaml.ci.dev/github/LiamSchilling/eventually-ocaml)

# Eventually

A small OCaml library for imposing logical time bounds on computations that may otherwise diverge.

## Usage

```sh
dune build            # Build the library and executable
dune runtest          # Run tests
dune exec eventually  # Run a small demonstration
```

## Examples

- [Newton's method](https://en.wikipedia.org/wiki/Newton%27s_method): [`newton.ml`](https://github.com/LiamSchilling/eventually-ocaml/blob/main/bin/newton.ml)
- [Hailstone sequences](https://en.wikipedia.org/wiki/Collatz_conjecture): [`hailstone.ml`](https://github.com/LiamSchilling/eventually-ocaml/blob/main/bin/hailstone.ml)

## Time-bounded computation

An `'a Eventually.eventually` is a computation subject to a logical time budget, which is consumed by way of `Eventually.tick n`.

```ocaml
let rec loop n =
  let* () = Eventually.tick 1 in  (* consume one tick *)
  Printf.printf "tick %d\n" n;    (* print "tick n" *)
  match n with
  | 0 -> Eventually.return "foo"  (* if `n=0` then return "foo" *)
  | _ -> loop (n - 1)             (* else decrement `n` and repeat *)
```

`Timer.incr n Timer.zero` supplies a budget of `n` ticks.

```ocaml
(* Prints "tick 3", "tick 2".
   Returns `Eventually.Timeout`. *)
let _ = Eventually.run (Timer.incr 2 Timer.zero) (loop 3)

(* Prints "tick 3", "tick 2", "tick 1", "tick 0".
   Returns `Eventually.Success "foo"`. *)
let _ = Eventually.run (Timer.incr 5 Timer.zero) (loop 3)

(* Prints "tick -4", "tick -5".
   Returns `Eventually.Timeout`. *)
let _ = Eventually.run (Timer.incr 2 Timer.zero) (loop -4)
```

`Timer.forever` supplies infinitely many ticks.

```ocaml
(* Prints "tick 3", "tick 2", "tick 1", "tick 0".
   Returns `Eventually.Success "foo"`. *)
let _ = Eventually.run (Timer.forever) (loop 3)

(* Prints "tick -4", "tick -5", "tick -6", "tick -7"...
   The computation diverges. *)
let _ = Eventually.run (Timer.forever) (loop -4)
```

## Project layout

```text
lib/   The Eventually and Supply library modules
bin/   The Hailstone demonstration executable
test/  Package tests
```
