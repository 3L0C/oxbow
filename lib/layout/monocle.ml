(* ocdwm monocle layout - monocle algorithm and related functions *)

open Ocdwm_core.Types
open Types

let name = "monocle"

let symbol =
  S_dynamic
    (fun ctx -> Printf.sprintf "[%d]" ctx.focused_index)

let compute
      ~(data : layout_params)
      ~(area : int rect)
      ~(count : int)
  =
  match count with
  | 0 -> []
  | n -> begin
      List.init n (fun i ->
        {
          x = area.x + data.gaps_outer;
          y = area.y + data.gaps_outer;
          w = area.w - (data.gaps_outer * 2);
          h = area.h - (data.gaps_outer * 2);
        })
    end
