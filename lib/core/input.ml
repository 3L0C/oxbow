module Class = struct
  type t =
    | Touchpad
    | Mouse

  let to_string = function
    | Touchpad -> "touchpad"
    | Mouse -> "mouse"
  ;;
end

module Role = struct
  type t =
    | Keyboard [@name "keyboard"]
    | Mouse [@name "mouse"]
    | Touchpad [@name "touchpad"]
    | Touch [@name "touch"]
    | Tablet [@name "tablet"]
  [@@deriving yojson]

  let to_string = function
    | Keyboard -> "keyboard"
    | Mouse -> "mouse"
    | Touchpad -> "touchpad"
    | Touch -> "touch"
    | Tablet -> "tablet"
  ;;
end
