open! Ocdwm_core

let pre (gaps : Params.Gaps.t) area =
  let by = max 0 (gaps.outer - (gaps.inner / 2)) in
  Rect.inset ~by area
;;

let post (gaps : Params.Gaps.t) rect = Rect.inset ~by:(gaps.inner / 2) rect
