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

let of_string str =
  match String.trim str with
  | s when String.ends_with ~suffix:"%" s ->
    (match String.split_on_char '%' s with
     | s :: _ ->
       (match float_of_string_opt s with
        | None -> Error (Printf.sprintf "bad extent: %s" str)
        | Some f -> Ok (Pct f))
     | _ -> Error (Printf.sprintf "bad extent: %s" str))
  | s ->
    (match int_of_string_opt s with
     | None -> Error (Printf.sprintf "bad extent: %s" str)
     | Some n -> Ok (Px n))
;;

let to_string = function
  | Px n -> Printf.sprintf "%d" n
  | Pct f -> Printf.sprintf "%f%%" f
;;
