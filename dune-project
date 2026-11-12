(lang dune 3.14)

(name eventually)

(version 0.2.0)

(generate_opam_files true)

(source
 (github LiamSchilling/eventually-ocaml))

(authors "William (Liam) Schilling")

(maintainers "William (Liam) Schilling")

(license MIT)

(documentation https://liamschilling.github.io/eventually-ocaml/)

(package
 (name eventually)
 (synopsis "Time-bounded computations and stream iteration")
 (description
  "This package exposes the `eventually` monad
   for computations run against a logical time budget,
   which may be infinite (risking that the computation diverges)
   or finite (resulting in a timeout instead).
   The package provides a reader/writer interface for stream processing,
   and implements time-bounded stream operations
   by way of the `eventually` monad.")
 (depends
  (ocaml (>= 4.14))
  (dune (>= 3.14)))
 (tags
  ("divergence"
   "lazy evaluation"
   "streams"
   "monads")))
