type t =
  | P_tiled
  | P_floating
  | P_fullscreen of { restore : [ `Tiled | `Floating ] }
