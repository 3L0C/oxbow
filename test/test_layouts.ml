open Oxbow_core
open Oxbow_layout

let pp (r : int Rect.t) = Printf.sprintf "(%d,%d) %dx%d" r.x r.y r.w r.h
let pps rects = String.concat " | " (List.map pp rects)

let () =
  let tile ~(ua : int Rect.t) ~scheme ~count ~nmaster ~mfact =
    let params = Params.Tiling.{ mfact; nmaster; dir = Left; scheme } in
    let rects = Schemes.compute ~params ~usable_area:ua ~count in
    Printf.printf
      "%s ua=(%d,%d,%dx%d) count=%d nmaster=%d mfact=%.2f:%s%s\n"
      (Scheme.to_string scheme)
      ua.x
      ua.y
      ua.w
      ua.h
      count
      nmaster
      mfact
      (if count > 0 then " " else "")
      (pps rects)
  in
  let full = Rect.{ x = 0; y = 0; w = 1920; h = 1080 } in
  List.iter
    (fun count ->
       List.iter
         (fun nmaster -> tile ~ua:full ~scheme:Scheme.Even ~count ~nmaster ~mfact:0.55)
         [ 1; 2 ])
    [ 0; 1; 2; 3; 5 ];
  tile
    ~ua:Rect.{ x = -100; y = 50; w = 800; h = 601 }
    ~scheme:Scheme.Even
    ~count:3
    ~nmaster:1
    ~mfact:0.5;
  tile
    ~ua:Rect.{ x = 0; y = 0; w = 7; h = 5 }
    ~scheme:Scheme.Even
    ~count:5
    ~nmaster:2
    ~mfact:0.5;
  List.iter
    (fun count -> tile ~ua:full ~scheme:Scheme.Deck ~count ~nmaster:1 ~mfact:0.55)
    [ 0; 1; 2; 3; 5 ];
  let strip ~(ua : int Rect.t) ~offset items =
    let placed = Strip.layout ~usable:ua ~offset items in
    Printf.printf
      "strip ua=(%d,%d,%dx%d) offset=%d:%s%s\n"
      ua.x
      ua.y
      ua.w
      ua.h
      offset
      (if List.length items > 0 then " " else "")
      (String.concat
         " | "
         (List.map (fun (i, r) -> Printf.sprintf "%d:%s" i (pp r)) placed))
  in
  let singletons facs =
    List.mapi (fun i fac -> i, Strip.Item.{ consumes = false; width_fac = fac }) facs
  in
  let ua = Rect.{ x = 0; y = 0; w = 1000; h = 600 } in
  List.iter
    (fun offset ->
       strip ~ua ~offset (singletons [ 0.5; 0.5; 0.5; 0.5 ]);
       strip ~ua ~offset (singletons [ 0.1; 0.5; 1.0; 0.66 ]))
    [ 0; 300 ];
  strip ~ua ~offset:0 (singletons []);
  strip
    ~ua
    ~offset:0
    [ 0, { consumes = true; width_fac = 0.5 }
    ; 1, { consumes = true; width_fac = 0.5 }
    ; 2, { consumes = false; width_fac = 0.5 }
    ; 3, { consumes = false; width_fac = 0.5 }
    ];
  let scroll name ~align ~viewport_w ~max_offset ~offset ~col:(x, w) =
    Strip.scroll ~align ~viewport_w ~max_offset ~offset ~col:(x, w)
    |> Printf.printf
         "scroll %s viewport=%d max=%d offset=%d col=(%d,%d): %d\n"
         name
         viewport_w
         max_offset
         offset
         x
         w
  in
  let vis = scroll ~align:Align.Visible ~viewport_w:1000 ~max_offset:2000 in
  vis "visible fully visible stays" ~offset:0 ~col:(0, 500);
  vis "visible edge flush stays" ~offset:0 ~col:(500, 500);
  vis "visible right slides minimally" ~offset:0 ~col:(1000, 500);
  vis "visible right slide clamps" ~offset:0 ~col:(1500, 500);
  vis "visible left slides onto" ~offset:500 ~col:(0, 500);
  vis "visible in view from offset stays" ~offset:500 ~col:(700, 500);
  vis "visible stale offset heals" ~offset:5000 ~col:(1500, 500);
  scroll
    "visible short strip zeroes"
    ~align:Align.Visible
    ~viewport_w:1000
    ~max_offset:600
    ~offset:400
    ~col:(0, 500);
  scroll
    "visible wide column pins left"
    ~align:Align.Visible
    ~viewport_w:1000
    ~max_offset:3000
    ~offset:0
    ~col:(300, 1500);
  let left = scroll ~align:Align.Left ~viewport_w:1000 ~max_offset:2000 ~offset:0 in
  left "left pins" ~col:(700, 500);
  left "left tail anchors" ~col:(1500, 500);
  let ctr = scroll ~align:Align.Centered ~viewport_w:1000 ~max_offset:2000 ~offset:0 in
  ctr "centered centers" ~col:(700, 500);
  ctr "centered clamps low" ~col:(100, 500);
  ctr "centered clamps high" ~col:(1500, 500)
;;
