type 'a t =
  { x : 'a
  ; y : 'a
  ; w : 'a
  ; h : 'a
  }

let to_int r = Int32.{ x = to_int r.x; y = to_int r.y; w = to_int r.w; h = to_int r.h }
let to_int32 r = Int32.{ x = of_int r.x; y = of_int r.y; w = of_int r.w; h = of_int r.h }

let inset ~by r =
  { x = r.x + by; y = r.y + by; w = max 1 (r.w - (2 * by)); h = max 1 (r.h - (2 * by)) }
;;

let contains ~x ~y g =
  x >= g.x && x < Int32.add g.x g.w && y >= g.y && y < Int32.add g.y g.h
;;

let intersect a b =
  let x0 = max a.x b.x in
  let y0 = max a.y b.y in
  let x1 = min (a.x + a.w) (b.x + b.w) in
  let y1 = min (a.y + a.h) (b.y + b.h) in
  if x0 < x1 && y0 < y1 then Some { x = x0; y = y0; w = x1 - x0; h = y1 - y0 } else None
;;
