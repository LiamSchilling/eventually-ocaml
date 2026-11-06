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
      - [None] if the supply is empty,
      - or [Some (e, w')] where [e] is the next element from the supply
        and [w'] is the rest of the supply. *)
  val emit : writer -> (elem * writer) option
end

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
      - [Ok r'] to request further elements from the supply as [r'],
      - or [Error x] to return the output value [x] and shutdown. *)
  val recv : reader -> elem -> (reader, output) result

  (** [shutdown r] consumes [r] returns an output value. *)
  val shutdown : reader -> output
end

module type SESSION = sig
  (** The type of elements. *)
  type elem

  (** The interface for the writer, which emits elements for the reader. *)
  module Writer : WRITER with type elem = elem

  (** The interface for the reader, which receives elements from the writer. *)
  module Reader : READER with type elem = elem
end
