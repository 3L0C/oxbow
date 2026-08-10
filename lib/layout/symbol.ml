open! Oxbow_core

module Ctx = struct
  type t =
    { focused_index : int
    ; count : int
    }
end

let render (layout : Layout.t) ~(scheme : Scheme.t) ~(align : Align.t) ~(ctx : Ctx.t) =
  match layout with
  | Floating -> "∘∘∘"
  | Scrolling ->
    (match align with
     | Left -> "=>>"
     | Centered -> ">=>"
     | Visible -> ">>=")
  | Tiling ->
    (match scheme with
     | Even -> "[]="
     | Diminish -> "[]>"
     | Dwindle -> "[\\]"
     | Spiral -> "[@]"
     | Deck -> "[D]"
     | Monocle -> Printf.sprintf "[%d]" ctx.focused_index)
;;
