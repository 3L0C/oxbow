open! Ocdwm_core

let compute (scheme : Scheme.t) =
  match scheme with
  | Tile -> Tile.compute
  | Monocle -> Monocle.compute
;;
