module Tile_or_float = struct
  type t =
    [ `Tiled
    | `Floating
    ]
end

module Fullscreen_prior = struct
  type t =
    [ Tile_or_float.t
    | `Maximized of Tile_or_float.t
    ]
end

type t =
  | P_tiled
  | P_floating
  | P_maximized of { restore : Tile_or_float.t }
  | P_fullscreen of { restore : Fullscreen_prior.t }
