# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - Unreleased

### Changed
- Separated `timer` functionality into its own `Timer` module:
  - `forever` is moved to the `Timer` module
- Changed interface of the `Eventually` module:
  - `tick n` now accepts count `n` of ticks to consume
  - `bind` is renamed to `sequence`
  - return type of `run` is a custom `now` variant type with more informative constructor names

### Added
- In module `Eventually`:
  - `forkjoin` to compose `eventually` computations "in parallel"
- In module `Timer`:
  - `zero` for the finished timer
  - `incr n` to increment the number of ticks left by `n`
  - `decr n` to decrement the number of ticks left by `n` and observe if the timer finishes
  - `min` to choose the timer with fewer ticks left
  - `max` to choose the timer with more ticks left

### Removed
- `until n` for `timer`
- `map` for `eventually`

## [0.1.0] - 2024-11-06

### Added
- `Eventually` module for imposing logical time bounds on computations that may otherwise diverge:
  - `timer` type:
    - `until n` for the timer that supplies `n` ticks
    - `forever` for the timer that supplies infinitely many ticks
  - `eventually` monad for computations subject to a logical time budget:
    - `tick` to consume one tick
    - monadic `return`, `map`, and `bind`
    - `run` to execute the computation with a designated timer
- `Supply` module, a reader/writer interface for stream processing:
  - `WRITER` module type for finite-or-infinite streams
  - `READER` module type for actors that process streams
  - `SESSION` module type, determining a complete interaction between a `WRITER` and a `READER`
  - `Run.run` to execute a `SESSION`, using `Eventually` to account for divergent sessions
- `Hailstone` demonstration using `Supply` to analyze [Hailstone sequences](https://en.wikipedia.org/wiki/Collatz_conjecture)

[0.2.0]: https://github.com/LiamSchilling/eventually-ocaml/compare/b259322...release/0.2.0
[0.1.0]: https://github.com/LiamSchilling/eventually-ocaml/commit/b259322
