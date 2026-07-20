open! Ppx_yojson_conv_lib.Yojson_conv

type t = int32

let r = Re.compile @@ Re.Pcre.re {|^(#|0[xX])?([0-9a-fA-F]+)$|}

let of_string s =
  let error () =
    Error
      (Printf.sprintf "invalid color %S: expected \"#RRGGBB\", \"0xRRGGBBAA\", etc." s)
  in
  let s = String.trim s in
  match Re.exec_opt r s with
  | None -> error ()
  | Some g ->
    let body = Re.Group.get g 2 in
    (match String.length body with
     | 6 -> Ok Int32.(logor (shift_left (of_string ("0x" ^ body)) 8) 0xFFl)
     | 8 -> Ok Int32.(of_string ("0x" ^ body))
     | _ -> error ())
;;

let of_string_exn s = of_string s |> Result.fold ~ok:Fun.id ~error:invalid_arg
let to_string c = Printf.sprintf "#%08lx" c

let channels c =
  let byte shift =
    let b = Int32.(shift_right_logical c shift |> logand 0xFFl) in
    Int32.mul b 0x01010101l
  in
  byte 24, byte 16, byte 8, byte 0
;;

let t_of_yojson (j : Yojson.Safe.t) =
  match j with
  | `String s ->
    (match of_string s with
     | Ok c -> c
     | Error e -> raise @@ Of_yojson_error (Failure e, j))
  | _ -> raise @@ Of_yojson_error (Failure "expected string", j)
;;

let yojson_of_t c = `String (to_string c)
