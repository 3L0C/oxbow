open! Ppx_yojson_conv_lib.Yojson_conv

module Kind = struct
  type t =
    | Tags
    | Window
    | Layout
    | Mode
    | Focus

  let all = [ Tags; Window; Layout; Mode ]
  let equal (a : t) (b : t) = a = b

  let of_string = function
    | "tags" -> Ok Tags
    | "window" -> Ok Window
    | "layout" -> Ok Layout
    | "mode" -> Ok Mode
    | "focus" -> Ok Focus
    | s -> Error (Printf.sprintf "unrecognized event kind: %s" s)
  ;;

  let to_string = function
    | Tags -> "tags"
    | Window -> "window"
    | Layout -> "layout"
    | Mode -> "mode"
    | Focus -> "focus"
  ;;

  let t_of_yojson = function
    | `String s ->
      (match of_string s with
       | Ok t -> t
       | Error msg -> failwith msg)
    | j -> of_yojson_error "Event.Kind.t_of_yojson: string expected" j
  ;;

  let yojson_of_t t = `String (to_string t)
end

module Tags = struct
  type t =
    { output : string
    ; viewed : int list
    ; occupied : int list
    ; urgent : int list
    ; focused : int list
    }
  [@@deriving yojson]
end

module Window = struct
  type t =
    { output : string
    ; title : string option
    ; app_id : string option
    }
  [@@deriving yojson]
end

module Layout = struct
  type t =
    { output : string
    ; layout : string
    ; symbol : string
    }
  [@@deriving yojson]
end

module Mode = struct
  type t =
    { seat : string
    ; mode : string
    }
  [@@deriving yojson]
end

module Focus = struct
  type t =
    { seat : string
    ; output : string option
    ; title : string option
    ; app_id : string option
    }
  [@@deriving yojson]
end

module Subscribe = struct
  type t =
    { kinds : Kind.t list
    ; output : string option
    }
  [@@deriving yojson]
end

type t =
  | Tags of Tags.t
  | Window of Window.t
  | Layout of Layout.t
  | Mode of Mode.t
  | Focus of Focus.t

let kind = function
  | Tags _ -> Kind.Tags
  | Window _ -> Kind.Window
  | Layout _ -> Kind.Layout
  | Mode _ -> Kind.Mode
  | Focus _ -> Kind.Focus
;;

let source = function
  | Tags { output = s; _ }
  | Window { output = s; _ }
  | Layout { output = s; _ }
  | Mode { seat = s; _ }
  | Focus { seat = s; _ } -> s
;;

let to_line t =
  let json k = function
    | `Assoc fields -> `Assoc (("event", `String k) :: fields) |> Yojson.Safe.to_string
    | _ -> assert false
  in
  match t with
  | Tags p -> json (Kind.to_string Kind.Tags) (Tags.yojson_of_t p)
  | Window p -> json (Kind.to_string Kind.Window) (Window.yojson_of_t p)
  | Layout p -> json (Kind.to_string Kind.Layout) (Layout.yojson_of_t p)
  | Mode p -> json (Kind.to_string Kind.Mode) (Mode.yojson_of_t p)
  | Focus p -> json (Kind.to_string Kind.Focus) (Focus.yojson_of_t p)
;;
