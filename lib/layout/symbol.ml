open! Oxbow_core

module Ctx = struct
  type t =
    { focused_index : int
    ; count : int
    }
end

let render (layout : Layout.t) ~(scheme : Scheme.t) ~(ctx : Ctx.t) =
  match layout with
  | Floating -> "∘∘∘"
  | Scrolling -> ">>="
  | Tiling ->
    (match scheme with
     | Even -> "[]="
     | Diminish -> "[]>"
     | Dwindle -> "[\\]"
     | Spiral -> "[@]"
     | Monocle -> Printf.sprintf "[%d]" ctx.focused_index)
;;
