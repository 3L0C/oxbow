(* ocdwm floating layout - floating algorithm and related functions *)

open Ocdwm_core.Types
open Types

let name = "floating"
let symbol = Symbol.S_static "><>"
let compute ~(data : Layout_params.t) ~(area : int Rect.t) ~(count : int) = []
