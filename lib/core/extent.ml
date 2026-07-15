open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | Px of int [@name "px"]
  | Pct of float [@name "pct"]
[@@deriving yojson]

let resolve ~ref:reference = function
  | Px n -> n
  | Pct f ->
    let r = float_of_int reference in
    f /. 100. *. r |> Float.round |> int_of_float
;;

let to_string = function
  | Px n -> Printf.sprintf "%d" n
  | Pct f -> Printf.sprintf "%f%%" f
;;

let of_string str =
  let error = Error (Printf.sprintf "bad extent: %s" str) in
  match String.trim str with
  | s when String.ends_with ~suffix:"%" s ->
    (match String.split_on_char '%' s with
     | s :: _ ->
       (match float_of_string_opt s with
        | None -> error
        | Some f -> Ok (Pct f))
     | _ -> error)
  | s ->
    (match int_of_string_opt s with
     | None -> error
     | Some n -> Ok (Px n))
;;
