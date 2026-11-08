(** The supply of integers from [0] to [max]. *)
module RangeWriter : Supply.WRITER
  with type elem = int
   and type init = int
= struct
  type elem = int
  type init = int
  type writer = int * int  (* (current, max) *)

  let make max = (0, max)

  let emit (current, max) =
    if current >= max then Supply.Data.End
    else Supply.Data.Emit (current, (current + 1, max))
end

(** A reader that sums all integers it receives. *)
module SumReader : Supply.READER
  with type elem = int
   and type init = unit
   and type output = int
= struct
  type elem = int
  type init = unit
  type output = int
  type reader = int  (* running sum *)

  let make () = 0

  let recv sum x = Supply.Data.Continue (sum + x)

  let shutdown sum = sum
end

(** A reader that counts elements received. *)
module CountReader : Supply.READER
  with type elem = int
   and type init = unit
   and type output = int
= struct
  type elem = int
  type init = unit
  type output = int
  type reader = int  (* count *)

  let make () = 0

  let recv count _ = Supply.Data.Continue (count + 1)

  let shutdown count = count
end

(** A reader that stops upon receiving the [n]th element. *)
module StopAfterNReader : Supply.READER
  with type elem = int
   and type init = int
   and type output = int
= struct
  type elem = int
  type init = int
  type output = int
  type reader = int * int  (* (count, limit) *)

  let make limit = (0, limit)

  let recv (count1, limit) _ =
    let count2 = count1 + 1 in
    if count2 >= limit then Supply.Data.Return count2
    else Supply.Data.Continue (count2, limit)

  let shutdown (count, _) = count
end

(** Session combining [RangeWriter] and [SumReader]. *)
module CountAndSumSession = Supply.Run(struct
  type elem = int
  module Writer = RangeWriter
  module Reader = SumReader
end)

(** Session combining [RangeWriter] and [CountReader]. *)
module CountAndCountSession = Supply.Run(struct
  type elem = int
  module Writer = RangeWriter
  module Reader = CountReader
end)

(** Session combining [RangeWriter] and [StopAfterNReader]. *)
module CountAndStopSession = Supply.Run(struct
  type elem = int
  module Writer = RangeWriter
  module Reader = StopAfterNReader
end)

let test_basic_supply () =
  (* Empty supply: writer makes 0 elements *)
  let writer = RangeWriter.make 0 in
  let reader = SumReader.make () in
  (match Eventually.run Timer.forever (CountAndSumSession.run writer reader) with
  | Success 0 -> ()
  | Success _ -> failwith "Empty supply should sum to 0"
  | Timeout -> failwith "Empty supply should not timeout");
  
  (* Small supply: 0+1+2 = 3 *)
  let writer = RangeWriter.make 3 in
  let reader = SumReader.make () in
  (match Eventually.run Timer.forever (CountAndSumSession.run writer reader) with
  | Success 3 -> ()  (* sum of 0, 1, 2 *)
  | Success _ -> failwith "Expected sum 3"
  | Timeout -> failwith "Small supply should not timeout");
  
  (* Larger supply *)
  let writer = RangeWriter.make 10 in
  let reader = SumReader.make () in
  (match Eventually.run Timer.forever (CountAndSumSession.run writer reader) with
  | Success 45 -> ()  (* sum of 0..9 = 45 *)
  | Success _ -> failwith "Expected sum 45"
  | Timeout -> failwith "Supply should not timeout");
  
  print_endline "✓ basic supply tests passed"

let test_supply_with_budget () =
  (* Generous budget: complete the whole supply *)
  let writer = RangeWriter.make 5 in
  let reader = CountReader.make () in
  let t = Timer.incr 100 Timer.zero in
  (match Eventually.run t (CountAndCountSession.run writer reader) with
  | Success 5 -> ()
  | Success _ -> failwith "Expected count 5"
  | Timeout -> failwith "Should complete with generous budget");
  
  (* Tight budget: may timeout before processing all elements *)
  let writer = RangeWriter.make 20 in
  let reader = CountReader.make () in
  let t = Timer.incr 3 Timer.zero in
  (match Eventually.run t (CountAndCountSession.run writer reader) with
  | Success _ -> failwith "Expected timeout"
  | Timeout -> ());
  
  (* Zero budget: should timeout immediately *)
  let writer = RangeWriter.make 10 in
  let reader = CountReader.make () in
  (match Eventually.run Timer.zero (CountAndCountSession.run writer reader) with
  | Success _ -> failwith "Expected timeout"
  | Timeout -> ());
  
  print_endline "✓ supply with budget tests passed"

let test_supply_early_shutdown () =
  (* Reader stops after 3 elements *)
  let writer = RangeWriter.make 10 in
  let reader = StopAfterNReader.make 3 in
  let t = Timer.incr 100 Timer.zero in
  (match Eventually.run t (CountAndStopSession.run writer reader) with
  | Success count ->
    if count = 3 then ()
    else failwith ("Expected count 3, got " ^ string_of_int count)
  | Timeout -> failwith "Should not timeout");
  
  (* Reader stops after 1 element *)
  let writer = RangeWriter.make 10 in
  let reader = StopAfterNReader.make 1 in
  let t = Timer.incr 100 Timer.zero in
  (match Eventually.run t (CountAndStopSession.run writer reader) with
  | Success count ->
    if count = 1 then ()
    else failwith ("Expected count 1, got " ^ string_of_int count)
  | Timeout -> failwith "Should not timeout");
  
  print_endline "✓ supply early shutdown tests passed"

let test_supply_edge_cases () =
  (* Empty supply with any reader *)
  let writer = RangeWriter.make 0 in
  let reader = CountReader.make () in
  (match Eventually.run Timer.forever (CountAndCountSession.run writer reader) with
  | Success 0 -> ()
  | Success _ -> failwith "Expected count 0"
  | Timeout -> failwith "Empty supply should not timeout");
  
  (* Empty supply with sum reader *)
  let writer = RangeWriter.make 0 in
  let reader = SumReader.make () in
  (match Eventually.run Timer.forever (CountAndSumSession.run writer reader) with
  | Success 0 -> ()
  | Success _ -> failwith "Expected sum 0"
  | Timeout -> failwith "Empty supply should not timeout");
  
  (* Single element supply *)
  let writer = RangeWriter.make 1 in
  let reader = CountReader.make () in
  (match Eventually.run Timer.forever (CountAndCountSession.run writer reader) with
  | Success 1 -> ()
  | Success _ -> failwith "Expected count 1"
  | Timeout -> failwith "Single element should not timeout");
  
  print_endline "✓ supply edge case tests passed"

let test () =
  test_basic_supply ();
  test_supply_with_budget ();
  test_supply_early_shutdown ();
  test_supply_edge_cases ()
