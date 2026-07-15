open! Ppx_yojson_conv_lib.Yojson_conv

module Pattern = struct
  type t =
    { app_id : string option
    ; title : string option
    }
  [@@deriving yojson]

  let equal { app_id = a_app_id; title = a_title } { app_id = b_app_id; title = b_title } =
    Option.equal String.equal a_app_id b_app_id
    && Option.equal String.equal a_title b_title
  ;;
end

module Action = struct
  type t =
    | Set_tags of Tag.Arg.t [@name "set_tags"]
    | Send_to_output of
        { name : string
        ; policy : Tag.Policy.t
        } [@name "send_to_output"]
    | Float [@name "float"]
    | Tile [@name "tile"]
    | Fullscreen [@name "fullscreen"]
    | Windowed [@name "windowed"]
  [@@deriving yojson]
end

type t =
  { pattern : Pattern.t
  ; action : Action.t
  }
[@@deriving yojson]

let equal a b =
  match a.action, b.action with
  | Float, Float | Tile, Tile | Fullscreen, Fullscreen | Windowed, Windowed -> true
  | Set_tags a_tags, Set_tags b_tags ->
    (match a_tags, b_tags with
     | Concrete a_tag, Concrete b_tag ->
       Tag.Set.equal a_tag b_tag && Pattern.equal a.pattern b.pattern
     | Occupied, Occupied -> Pattern.equal a.pattern b.pattern
     | _, _ -> false)
  | ( Send_to_output { name = a_name; policy = a_policy }
    , Send_to_output { name = b_name; policy = b_policy } ) ->
    String.equal a_name b_name && a_policy = b_policy && Pattern.equal a.pattern b.pattern
  | _, _ -> false
;;
