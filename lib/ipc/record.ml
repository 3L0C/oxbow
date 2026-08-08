open! Ppx_yojson_conv_lib.Yojson_conv

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
    { id : int
    ; identifier : string option
    ; title : string option
    ; app_id : string option
    ; output : string option
    ; tags : int list
    ; focused : bool
    ; urgent : bool
    ; hidden : bool
    ; presentation : string
    ; sticky : string
    ; swallowing : bool
    ; labels : string list
    }
  [@@deriving yojson]
end

module Output = struct
  type t =
    { name : string
    ; labels : string list
    ; focused : bool
    }
  [@@deriving yojson]
end

module Layout = struct
  type t =
    { output : string
    ; layout : string
    ; scheme : string option
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
    ; tags : int list option
    }
  [@@deriving yojson]
end

type t =
  | Tags
  | Window
  | Layout
  | Mode
  | Focus

let all = [ Tags; Window; Layout; Mode; Focus ]
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
  | j -> of_yojson_error "Record.t_of_yojson: string expected" j
;;

let yojson_of_t t = `String (to_string t)
