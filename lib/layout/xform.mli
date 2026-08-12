(** [pre dir area] is the area a canonical (left-master) layout fills: [area]
    itself for [Left]/[Right]; for [Up]/[Down], origin-anchored with width and
    height swapped, so mfact applies to real height. [dir] is the master
    placement. *)
val pre
  :  Oxbow_core.Direction.Spatial.t
  -> int Oxbow_core.Rect.t
  -> int Oxbow_core.Rect.canonical

(** [post dir ~area rect] maps a canonical rect back to screen space: swaps axes
    back for [Up]/[Down], mirrors for [Right]/[Down], translates into [area].
    [Left] is the identity. *)
val post
  :  Oxbow_core.Direction.Spatial.t
  -> area:int Oxbow_core.Rect.t
  -> int Oxbow_core.Rect.canonical
  -> int Oxbow_core.Rect.t
