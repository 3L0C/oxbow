type 'a t =
  { x : 'a
  ; y : 'a
  ; w : 'a
  ; h : 'a
  }

let to_int r = Int32.{ x = to_int r.x; y = to_int r.y; w = to_int r.w; h = to_int r.h }
