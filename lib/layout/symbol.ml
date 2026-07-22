open! Ocdwm_core

module Ctx = struct
  type t =
    { focused_index : int
    ; count : int
    }
end

let render (layout : Layout.t) ~(scheme : Scheme.t) ~(stack : Stack_kind.t) ~(ctx : Ctx.t)
  =
  match layout with
  | Floating -> "∘∘∘"
  | Scrolling -> ">>="
  | Tiling ->
    (match scheme with
     | Monocle -> Printf.sprintf "[%d]" ctx.focused_index
     | Tile ->
       (match stack with
        | Even -> "[]="
        | Diminish -> "[]>"
        | Dwindle -> "[\\]"
        | Spiral -> "[@]"))
;;
