type 'a t =
  { x : 'a
  ; y : 'a
  ; w : 'a
  ; h : 'a
  }

let to_int r = Int32.{ x = to_int r.x; y = to_int r.y; w = to_int r.w; h = to_int r.h }

let inset ~by r =
  { x = r.x + by; y = r.y + by; w = max 1 (r.w - (2 * by)); h = max 1 (r.h - (2 * by)) }
;;
