module type WRITER = Supply_intf.WRITER
module type READER = Supply_intf.READER
module type SESSION = Supply_intf.SESSION

let ( let* ) y f = Eventually.sequence y f

module Run(Session : SESSION) = struct
  let rec run w1 r1 =
    let* () = Eventually.tick 1 in
    match Session.Writer.emit w1 with
    | None -> Session.Reader.shutdown r1 |> Eventually.return
    | Some (e, w2) ->
      match Session.Reader.recv r1 e with
      | Ok r2 -> run w2 r2
      | Error x -> Eventually.return x
end
