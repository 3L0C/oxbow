(* Property checks for [Tile.compute]. The compute stage is gapless: the arrange
   pipeline applies gaps with [Gaps.pre] and [Gaps.post], so the result must not
   depend on the gaps params. The rect count matches the window count. In
   non-degenerate configurations (each column holds at least one pixel per
   window) the tiles fill the usable area exactly: outer edges flush, adjacent
   tiles flush, no overlaps. Degenerate configurations only need non-negative
   dimensions. *)

let test_tiling () =
  let open Ocdwm_core in
  let open Ocdwm_layout in
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
    let params =
      Params.
        { mfact
        ; nmaster
        ; gaps_inner = gi
        ; gaps_outer = go
        ; stack = Even
        ; dir = Left
        ; scroll_policy = Visible
        }
    in
    let rects = Tile.compute ~params ~usable_area:ua ~count in
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

let () = test_tiling ()
