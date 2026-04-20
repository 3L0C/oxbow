(* ocdwm floating layout - floating algorithm and related functions *)

open Ocdwm_core.Types
open Types

let name = "floating"
let symbol = S_static "><>"

let compute
      ~(data : layout_params)
      ~(area : int rect)
      ~(count : int)
  =
  []
