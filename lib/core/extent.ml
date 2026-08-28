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
  let error s = Error (Printf.sprintf "bad extent: %s" s) in
  match String.trim str with
  | str' when String.ends_with ~suffix:"%" str' ->
    (match String.split_on_char '%' str' with
     | s :: _ ->
       (match float_of_string_opt s with
        | None -> error str'
        | Some f -> Ok (Pct f))
     | _ -> error str')
  | str' ->
    (match int_of_string_opt str' with
     | None -> error str'
     | Some n -> Ok (Px n))
;;
