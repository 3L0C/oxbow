module Case = struct
  type t =
    | Sensitive [@name "sensitive"]
    | Insensitive [@name "insensitive"]
  [@@deriving yojson]
end

let re_compile ~(case : Case.t) s =
  let flags =
    match case with
    | Sensitive -> []
    | Insensitive -> [ `CASELESS ]
  in
  try Ok Re.(compile (Pcre.re ~flags s)) with
  | Re.Pcre.(Parse_error | Not_supported) -> Error (Printf.sprintf "invalid regex: %s" s)
;;

let matches ~case ~pattern str =
  match pattern with
  | None -> true
  | Some s ->
    (match re_compile ~case s with
     | Error msg ->
       Logs.err (fun m -> m "%s" msg);
       false
     | Ok re -> Re.execp re str)
;;

let compile_specs ~case specs =
  List.fold_left
    (fun acc (pattern, proj) ->
       Result.bind acc
       @@ fun preds ->
       match pattern with
       | None -> Ok preds
       | Some s ->
         Result.map
           (fun re subj -> List.exists (Re.execp re) (proj subj))
           (re_compile ~case s)
         |> Result.map (fun pred -> pred :: preds))
    (Ok [])
    specs
  |> Result.map (fun preds subj -> List.for_all (fun pred -> pred subj) preds)
;;
