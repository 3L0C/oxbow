open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  { pattern : Rule_pattern.t
  ; action : Rule_action.t
  }
[@@deriving yojson]

let equal a b =
  match a.action, b.action with
  | Float, Float | Tile, Tile | Fullscreen, Fullscreen | Windowed, Windowed -> true
  | Set_tags a_tags, Set_tags b_tags ->
    (match a_tags, b_tags with
     | Tags_concrete a_tag, Tags_concrete b_tag ->
       Tag_set.equal a_tag b_tag && Rule_pattern.equal a.pattern b.pattern
     | Tags_occupied, Tags_occupied -> Rule_pattern.equal a.pattern b.pattern
     | _, _ -> false)
  | ( Send_to_output { name = a_name; policy = a_policy }
    , Send_to_output { name = b_name; policy = b_policy } ) ->
    String.equal a_name b_name
    && a_policy = b_policy
    && Rule_pattern.equal a.pattern b.pattern
  | _, _ -> false
;;
