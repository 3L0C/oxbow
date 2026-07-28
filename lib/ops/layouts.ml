open! Ocdwm_state
open! Ocdwm_ipc

let handle_scrolling ctx seat (cmd : Command.Layout.Scrolling.t) =
  let wm = Ctx.wm ctx in
  match cmd with
  | Column_width { delta; global } -> Column.set_width seat delta ~global
  | Policy { policy; global } -> Arrange.set_scroll_policy wm seat policy ~global
;;

let handle_tiling seat (cmd : Command.Layout.Tiling.t) =
  match cmd with
  | Cycle dir -> Arrange.cycle_scheme seat dir
  | Mfact { delta; global } -> Arrange.set_mfact seat delta ~global
  | Nmaster { delta; global } -> Arrange.set_nmaster seat delta ~global
  | Orientation { dir; global } -> Arrange.set_orientation seat dir ~global
  | Scheme { scheme; global } -> Arrange.select_scheme seat scheme ~global
;;

let handle ctx seat (cmd : Command.Layout.t) =
  match cmd with
  | Cycle dir -> Arrange.cycle_layout seat dir
  | Select { layout; global } -> Arrange.set_layout seat layout ~global
  | Scrolling c -> handle_scrolling ctx seat c
  | Tiling c -> handle_tiling seat c
;;
