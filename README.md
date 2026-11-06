# Eventually

A small OCaml library for imposing logical time bounds on computations that may diverge.

## Usage

```sh
dune build            # Build the library and executable
dune runtest          # Run tests
dune exec eventually  # Run a small demonstration
```

## Time-bounded computations

An `'a Eventually.eventually` is a computation subject to a logical time budget, which is consumed by way of `Eventually.tick`.

```ocaml
let rec loop n =
  let* () = Eventually.tick in
  Printf.printf "tick %d\n" n;
  match n with
  | 0 -> Eventually.return "foo"
  | _ -> loop (n - 1)
```

`Eventually.until n` supplies a budget of `n` ticks.

```ocaml
(* Prints "tick 3", "tick 2".
   Returns [None]. *)
let _ = Eventually.run (Eventually.until 2) (loop 3)

(* Prints "tick 3", "tick 2", "tick 1", "tick 0".
   Returns [Some "foo"]. *)
let _ = Eventually.run (Eventually.until 5) (loop 3)

(* Prints "tick -4", "tick -5".
   Returns [None]. *)
let _ = Eventually.run (Eventually.until 2) (loop -4)
```

`Eventually.forever` supplies infinitely many ticks.

```ocaml
(* Prints "tick 3", "tick 2", "tick 1", "tick 0".
   Returns [Some "foo"]. *)
let _ = Eventually.run (Eventually.forever) (loop 3)

(* Prints "tick -4", "tick -5", "tick -6", "tick -7"...
   The computation diverges. *)
let _ = Eventually.run (Eventually.forever) (loop -4)
```

## Project layout

```text
lib/   The Eventually and Supply library modules
bin/   The Hailstone demonstration executable
test/  Package tests
```
