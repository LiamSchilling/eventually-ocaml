(** Defines domain-specific variant types. *)
module Data = struct
  (** The result of observing a supply. *)
  type ('a, 'b) emission =
    | End
    | Emit of 'a * 'b

  (** The decision of a supply reader after processing one element. *)
  type ('a, 'b) verdict =
    | Continue of 'a
    | Return of 'b
end

(** An interface for finite-or-infinite supplies. *)
module type WRITER = sig
  (** The type of elements. *)
  type elem

  (** Initialization data for a writer. *)
  type init

  (** A value of type [writer] is a finite-or-infinite supply of elements. *)
  type writer

  (** Construct a new writer. *)
  val make : init -> writer

  (** [emit w] consumes [w] and returns either
      - [Empty] if the supply is empty,
      - or [Emit (e, w')] where [e] is the next element from the supply
        and [w'] is the rest of the supply. *)
  val emit : writer -> (elem, writer) Data.emission
end

(** An interface for actors that process supplies. *)
module type READER = sig
  (** The type of elements. *)
  type elem

  (** Initialization data for a reader. *)
  type init

  (** The type of the reader's final output after processing the supply. *)
  type output

  (** A value of type [reader] is an agent that processes a supply of elements,
      and may at any point decide to return an output value and shutdown. *)
  type reader

  (** Construct a new reader. *)
  val make : init -> reader

  (** If [e] is the next element from the supply,
      then [recv r e] consumes [r] and returns either
      - [Continue r'] to request further elements from the supply as [r'],
      - or [Return x] to return the output value [x] and shutdown. *)
  val recv : reader -> elem -> (reader, output) Data.verdict

  (** [shutdown r] consumes [r] returns an output value. *)
  val shutdown : reader -> output
end

(** Determines a complete interaction between a [WRITER] and a [READER]. *)
module type SESSION = sig
  (** The type of elements. *)
  type elem

  (** The interface for the writer, which emits elements for the reader. *)
  module Writer : WRITER with type elem = elem

  (** The interface for the reader, which receives elements from the writer. *)
  module Reader : READER with type elem = elem
end
