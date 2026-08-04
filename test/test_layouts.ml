(* Property checks for [Tile.compute]. The compute stage is gapless: the arrange
   pipeline applies gaps with [Gaps.pre] and [Gaps.post], so the result must not
   depend on the gaps params. The rect count matches the window count. In
   non-degenerate configurations (each column holds at least one pixel per
   window) the tiles fill the usable area exactly: outer edges flush, adjacent
   tiles flush, no overlaps. Degenerate configurations only need non-negative
   dimensions. *)

let test_tiling () =
  let open Oxbow_core in
  let open Oxbow_layout in
  let cases = ref 0 in
  let failures = ref 0 in
  let overlaps (a : int Rect.t) (b : int Rect.t) =
    a.x < b.x + b.w && b.x < a.x + a.w && a.y < b.y + b.h && b.y < a.y + a.h
  in
  let run ~(ua : int Rect.t) ~count ~nmaster ~mfact ~gi ~go =
    incr cases;
    let fail name =
      incr failures;
      if !failures <= 10
      then
        Printf.printf
          "FAIL %s: ua=(%d,%d,%dx%d) count=%d nmaster=%d mfact=%.2f gi=%d go=%d\n"
          name
          ua.x
          ua.y
          ua.w
          ua.h
          count
          nmaster
          mfact
          gi
          go
    in
    let check name cond = if not cond then fail name in
    let params = Params.Tiling.{ mfact; nmaster; dir = Left; scheme = Even } in
    let rects = Schemes.compute ~params ~usable_area:ua ~count in
    check "rect count" (List.length rects = count);
    List.iter (fun (r : int Rect.t) -> check "dims sane" (r.w >= 0 && r.h >= 0)) rects;
    if count > 0 && List.length rects = count
    then (
      let m_count = min count nmaster in
      let c_count = count - m_count in
      let w_raw = ua.w in
      let mh_raw = ua.h in
      let ch_raw = ua.h in
      let nondegen =
        w_raw >= max 2 count
        && (m_count = 0 || mh_raw >= m_count)
        && (c_count = 0 || ch_raw >= c_count)
      in
      if nondegen
      then (
        let masters = List.filteri (fun i _ -> i < m_count) rects in
        let clients = List.filteri (fun i _ -> i >= m_count) rects in
        List.iteri
          (fun i a ->
             List.iteri
               (fun j b -> if j > i then check "no overlap" (not (overlaps a b)))
               rects)
          rects;
        List.iter
          (fun (r : int Rect.t) ->
             check
               "in bounds"
               (r.x >= ua.x
                && r.y >= ua.y
                && r.x + r.w <= ua.x + ua.w
                && r.y + r.h <= ua.y + ua.h))
          rects;
        let column name (col : int Rect.t list) =
          match col with
          | [] -> ()
          | first :: _ ->
            let last = List.nth col (List.length col - 1) in
            check (name ^ " top flush") (first.y = ua.y);
            check (name ^ " bottom flush") (last.y + last.h = ua.y + ua.h);
            ignore
              (List.fold_left
                 (fun (prev : int Rect.t option) (r : int Rect.t) ->
                    (match prev with
                     | Some p -> check (name ^ " vertical flush") (r.y = p.y + p.h)
                     | None -> ());
                    Some r)
                 None
                 col)
        in
        column "master" masters;
        column "client" clients;
        (match masters with
         | m :: _ -> check "master left flush" (m.x = ua.x)
         | [] -> ());
        (match clients, masters with
         | c :: _, m :: _ -> check "column flush" (c.x = m.x + m.w)
         | c :: _, [] -> check "client left flush" (c.x = ua.x)
         | [], _ -> ());
        match List.rev rects with
        | r :: _ -> check "right flush" (r.x + r.w = ua.x + ua.w)
        | [] -> ()))
  in
  List.iter
    (fun (uw, uh) ->
       List.iter
         (fun (ux, uy) ->
            List.iter
              (fun count ->
                 List.iter
                   (fun nmaster ->
                      List.iter
                        (fun mfact ->
                           List.iter
                             (fun gi ->
                                List.iter
                                  (fun go ->
                                     run
                                       ~ua:Rect.{ x = ux; y = uy; w = uw; h = uh }
                                       ~count
                                       ~nmaster
                                       ~mfact
                                       ~gi
                                       ~go)
                                  [ 0; 1; 5; 20; 45; 300 ])
                             [ 0; 1; 5; 10; 37; 200 ])
                        [ 0.05; 0.1; 0.5; 0.55; 0.9; 0.95 ])
                   [ 0; 1; 2; 3; 5; 8; 100 ])
              [ 0; 1; 2; 3; 4; 5; 6; 7; 8 ])
         [ 0, 0; 1920, 0; -100, 50 ])
    [ 1920, 1080; 1280, 720; 800, 600; 3840, 2160; 640, 480; 100, 100; 50, 40; 7, 5 ];
  Printf.printf "tile: %d cases, %d failures\n" !cases !failures;
  if !failures > 0 then exit 1
;;

(* Property checks for [Strip.layout] and [Strip.scroll]. Singleton items make
   one full-height column each: the head factor sets the width, and the x
   positions advance by exactly one column width. A consumes chain puts its
   members in one shared column, and the member heights split the usable height
   exactly. A non-zero offset only shifts x. [Strip.scroll] keeps the result
   inside [0, max 0 max_offset] for all inputs; concrete cases pin
   the policy rules. *)

let test_scrolling () =
  let open Oxbow_core in
  let open Oxbow_layout in
  let cases = ref 0 in
  let failures = ref 0 in
  let overlaps (a : int Rect.t) (b : int Rect.t) =
    a.x < b.x + b.w && b.x < a.x + a.w && a.y < b.y + b.h && b.y < a.y + a.h
  in
  let item ~consumes ~fac : Strip.Item.t = { consumes; width_fac = fac } in
  let run_singletons ~(ua : int Rect.t) ~offset ~facs =
    incr cases;
    let fail name =
      incr failures;
      if !failures <= 10
      then
        Printf.printf
          "FAIL %s: ua=(%d,%d,%dx%d) offset=%d facs=%d\n"
          name
          ua.x
          ua.y
          ua.w
          ua.h
          offset
          (List.length facs)
    in
    let check name cond = if not cond then fail name in
    let items = List.mapi (fun i fac -> i, item ~consumes:false ~fac) facs in
    let placed = Strip.layout ~usable:ua ~offset items in
    check "rect count" (List.length placed = List.length items);
    if List.length placed = List.length items
    then (
      List.iter
        (fun (_, (r : int Rect.t)) -> check "full height" (r.y = ua.y && r.h = ua.h))
        placed;
      List.iter2
        (fun fac (_, (r : int Rect.t)) ->
           check "width" (r.w = (float_of_int ua.w *. fac |> int_of_float |> max 1)))
        facs
        placed;
      (match placed with
       | (_, (r : int Rect.t)) :: _ -> check "first x" (r.x = ua.x - offset)
       | [] -> ());
      ignore
        (List.fold_left
           (fun (prev : int Rect.t option) (_, (r : int Rect.t)) ->
              (match prev with
               | Some p -> check "x advance" (r.x = p.x + p.w)
               | None -> ());
              Some r)
           None
           placed);
      List.iteri
        (fun i (_, a) ->
           List.iteri
             (fun j (_, b) -> if j > i then check "no overlap" (not (overlaps a b)))
             placed)
        placed;
      let placed0 = Strip.layout ~usable:ua ~offset:0 items in
      List.iter2
        (fun (_, (a : int Rect.t)) (_, (b : int Rect.t)) ->
           check
             "offset shifts x only"
             (a.x = b.x - offset && a.y = b.y && a.w = b.w && a.h = b.h))
        placed
        placed0)
  in
  (* consumes points forward: [c; c; nc; nc] derives [[0; 1; 2]; [3]] *)
  let run_chain ~(ua : int Rect.t) ~offset ~fac =
    incr cases;
    let fail name =
      incr failures;
      if !failures <= 10
      then
        Printf.printf
          "FAIL chain %s: ua=(%d,%d,%dx%d) offset=%d fac=%.2f\n"
          name
          ua.x
          ua.y
          ua.w
          ua.h
          offset
          fac
    in
    let check name cond = if not cond then fail name in
    let items =
      [ 0, item ~consumes:true ~fac
      ; 1, item ~consumes:true ~fac
      ; 2, item ~consumes:false ~fac
      ; 3, item ~consumes:false ~fac
      ]
    in
    match Strip.layout ~usable:ua ~offset items with
    | [ (_, (r0 : int Rect.t)); (_, r1); (_, r2); (_, r3) ] ->
      check "column shares x" (r0.x = r1.x && r1.x = r2.x);
      check "column shares width" (r0.w = r1.w && r1.w = r2.w);
      check "heights sum" (r0.h + r1.h + r2.h = ua.h);
      check "column top" (r0.y = ua.y);
      check "stacked" (r1.y = r0.y + r0.h && r2.y = r1.y + r1.h);
      check "two columns" (r3.x = r0.x + r0.w);
      check "second column full height" (r3.y = ua.y && r3.h = ua.h);
      check "first x" (r0.x = ua.x - offset)
    | _ -> fail "rect count"
  in
  let run_scroll ~(policy : Scroll_policy.t) ~viewport_w ~max_offset ~offset ~col:(x, w) =
    incr cases;
    let fail name =
      incr failures;
      if !failures <= 10
      then
        Printf.printf
          "FAIL %s: policy=%s viewport=%d total=%d offset=%d col=(%d,%d)\n"
          name
          (match policy with
           | Visible -> "visible"
           | Left -> "left"
           | Centered -> "centered")
          viewport_w
          max_offset
          offset
          x
          w
    in
    let check name cond = if not cond then fail name in
    let res = Strip.scroll ~policy ~viewport_w ~max_offset ~offset ~col:(x, w) in
    let hi = max 0 max_offset in
    let clamp v = min v hi |> max 0 in
    if policy <> Centered then check "in bounds" (0 <= res && res <= hi);
    match policy with
    | Left -> check "left pins" (res = clamp x)
    | Centered -> check "centered" (res = x - ((viewport_w - w) / 2))
    | Visible ->
      if w > viewport_w then check "wide pins left" (res = clamp x);
      if w <= viewport_w && max_offset >= viewport_w && x >= 0 && x <= max_offset
      then check "focus visible after" (res <= x && x + w <= res + viewport_w);
      if x >= offset && x + w <= offset + viewport_w && 0 <= offset && offset <= hi
      then check "in view stays" (res = offset)
  in
  let expect name ~policy ~viewport_w ~max_offset ~offset ~col v =
    incr cases;
    let res = Strip.scroll ~policy ~viewport_w ~max_offset ~offset ~col in
    if res <> v
    then (
      incr failures;
      if !failures <= 10 then Printf.printf "FAIL %s: got %d, want %d\n" name res v)
  in
  let uas =
    Rect.
      [ { x = 0; y = 0; w = 1000; h = 600 }
      ; { x = 0; y = 0; w = 1920; h = 1080 }
      ; { x = -100; y = 50; w = 800; h = 601 }
      ; { x = 0; y = 0; w = 7; h = 5 }
      ]
  in
  List.iter
    (fun ua ->
       List.iter
         (fun offset ->
            List.iter
              (fun facs -> run_singletons ~ua ~offset ~facs)
              [ []
              ; [ 0.5 ]
              ; [ 0.5; 0.5; 0.5; 0.5 ]
              ; [ 0.1; 0.5; 1.0; 0.66 ]
              ; [ 0.33; 0.33; 0.33 ]
              ];
            List.iter (fun fac -> run_chain ~ua ~offset ~fac) [ 0.34; 0.5; 1.0 ])
         [ 0; 1; 300; 5000 ])
    uas;
  List.iter
    (fun policy ->
       List.iter
         (fun viewport_w ->
            List.iter
              (fun max_offset ->
                 List.iter
                   (fun offset ->
                      List.iter
                        (fun x ->
                           List.iter
                             (fun w ->
                                run_scroll
                                  ~policy
                                  ~viewport_w
                                  ~max_offset
                                  ~offset
                                  ~col:(x, w))
                             [ 1; 300; 500; 1200 ])
                        [ 0; 450; 999; 1500; 4500 ])
                   [ 0; 1; 450; 5000 ])
              [ 200; 1000; 2000; 5000 ])
         [ 500; 1000 ])
    Scroll_policy.[ Visible; Left; Centered ];
  let vis = expect ~policy:Visible ~viewport_w:1000 ~max_offset:2000 in
  vis "fully visible stays" ~offset:0 ~col:(0, 500) 0;
  vis "edge flush stays" ~offset:0 ~col:(500, 500) 0;
  vis "right slides minimally" ~offset:0 ~col:(1000, 500) 500;
  vis "right slide clamps" ~offset:0 ~col:(1500, 500) 1000;
  vis "left slides onto" ~offset:500 ~col:(0, 500) 0;
  vis "in view from offset stays" ~offset:500 ~col:(700, 500) 500;
  vis "stale offset heals" ~offset:5000 ~col:(1500, 500) 1500;
  expect
    "short strip zeroes"
    ~policy:Visible
    ~viewport_w:1000
    ~max_offset:600
    ~offset:400
    ~col:(0, 500)
    0;
  expect
    "wide column pins left"
    ~policy:Visible
    ~viewport_w:1000
    ~max_offset:3000
    ~offset:0
    ~col:(300, 1500)
    300;
  let left = expect ~policy:Left ~viewport_w:1000 ~max_offset:2000 ~offset:0 in
  left "left pins" ~col:(700, 500) 700;
  left "tail anchors left" ~col:(1500, 500) 1500;
  let ctr = expect ~policy:Centered ~viewport_w:1000 ~max_offset:2000 ~offset:0 in
  ctr "centers" ~col:(700, 500) 450;
  ctr "center clamps low" ~col:(100, 500) (-150);
  ctr "center clamps high" ~col:(1500, 500) 1250;
  Printf.printf "strip: %d cases, %d failures\n" !cases !failures;
  if !failures > 0 then exit 1
;;

let () =
  test_tiling ();
  test_scrolling ()
;;
