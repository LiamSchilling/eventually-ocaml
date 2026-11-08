module Data = Supply_intf.Data
module type WRITER = Supply_intf.WRITER
module type READER = Supply_intf.READER
module type SESSION = Supply_intf.SESSION

module Run : functor(Session : SESSION) -> sig
  (** [run w r] consumes [w] and [r], and returns a time-bounded computation
      that converges to the result of [r] processing the entire supply [w]. *)
  val run :
    Session.Writer.writer ->
    Session.Reader.reader ->
    Session.Reader.output Eventually.eventually
end
