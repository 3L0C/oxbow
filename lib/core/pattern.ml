let src = Logs.Src.create "oxbow.core" ~doc:"oxbow core library"

module Log = (val Logs.src_log src)

module Case = struct
  type t =
    | Sensitive [@name "sensitive"]
    | Insensitive [@name "insensitive"]
  [@@deriving yojson]
end

let cache : (Case.t * string, (Re.re, string) result) Hashtbl.t = Hashtbl.create 64

let re_compile_uncached ~(case : Case.t) s =
  let flags =
    match case with
    | Sensitive -> []
    | Insensitive -> [ `CASELESS ]
  in
  try Ok Re.(compile (Pcre.re ~flags s)) with
  | Re.Pcre.(Parse_error | Not_supported) -> Error (Printf.sprintf "invalid regex: %s" s)
;;

let re_compile ~case s =
  match Hashtbl.find_opt cache (case, s) with
  | Some r -> r
  | None ->
    let r = re_compile_uncached ~case s in
    if Hashtbl.length cache > 1024 then Hashtbl.reset cache;
    Hashtbl.add cache (case, s) r;
    r
;;

let matches ~case ~pattern str =
  match pattern with
  | None -> true
  | Some s ->
    (match re_compile ~case s with
     | Error msg ->
       Log.err (fun m -> m "%s" msg);
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
