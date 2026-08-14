open! Ppx_yojson_conv_lib.Yojson_conv

module Subscribe = struct
  type t =
    { kinds : Record.t list
    ; output : string option
    }
  [@@deriving yojson]
end

type t =
  | Tags of Record.Tags.t
  | Window of Record.Window.t
  | Window_cleared of string
  | Layout of Record.Layout.t
  | Mode of Record.Mode.t
  | Focus of Record.Focus.t
  | Output of Record.Output.t

let kind = function
  | Tags _ -> Record.Tags
  | Window _ | Window_cleared _ -> Record.Window
  | Layout _ -> Record.Layout
  | Mode _ -> Record.Mode
  | Focus _ -> Record.Focus
  | Output _ -> Record.Output
;;

let source = function
  | Tags { output = s; _ }
  | Window { output = Some s; _ }
  | Layout { output = s; _ }
  | Mode { seat = s; _ }
  | Focus { seat = s; _ }
  | Output { name = Some s; _ } -> Ok s
  | Window_cleared s -> Ok s
  | Window { output = None; _ } -> Error "window without any output"
  | Output { name = None; _ } -> Error "output without a name"
;;

let to_line t =
  let json k = function
    | `Assoc fields -> `Assoc (("event", `String k) :: fields) |> Yojson.Safe.to_string
    | _ -> assert false
  in
  match t with
  | Tags p -> json (Record.to_string Record.Tags) (Record.Tags.yojson_of_t p)
  | Window p -> json (Record.to_string Record.Window) (Record.Window.yojson_of_t p)
  | Window_cleared output ->
    json (Record.to_string Record.Window) (`Assoc [ "output", `String output ])
  | Layout p -> json (Record.to_string Record.Layout) (Record.Layout.yojson_of_t p)
  | Mode p -> json (Record.to_string Record.Mode) (Record.Mode.yojson_of_t p)
  | Focus p -> json (Record.to_string Record.Focus) (Record.Focus.yojson_of_t p)
  | Output p -> json (Record.to_string Record.Output) (Record.Output.yojson_of_t p)
;;
