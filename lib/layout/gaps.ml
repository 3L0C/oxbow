open! Ocdwm_core

let pre (params : Params.t) area =
  let by = max 0 (params.gaps_outer - (params.gaps_inner / 2)) in
  Rect.inset ~by area
;;

let post (params : Params.t) rect = Rect.inset ~by:(params.gaps_inner / 2) rect
