open! Ocdwm_ipc

let handle_scrolling wm seat (cmd : Command.Layout.Scrolling.t) =
  match cmd with
  | Policy { policy; scope } -> Arrange.set_scroll_policy wm seat policy scope
  | Default_width { delta; scope } -> Arrange.set_default_width wm seat delta scope
;;

let handle_tiling wm seat (cmd : Command.Layout.Tiling.t) =
  match cmd with
  | Cycle dir -> Arrange.cycle_scheme wm seat dir
  | Mfact { delta; scope } -> Arrange.set_mfact wm seat delta scope
  | Nmaster { delta; scope } -> Arrange.set_nmaster wm seat delta scope
  | Orientation { dir; scope } -> Arrange.set_orientation wm seat dir scope
  | Scheme { scheme; scope } -> Arrange.select_scheme wm seat scheme scope
;;

let handle wm seat (cmd : Command.Layout.t) =
  match cmd with
  | Cycle dir -> Arrange.cycle_layout wm seat dir
  | Select { layout; scope } -> Arrange.set_layout wm seat layout scope
  | Scrolling c -> handle_scrolling wm seat c
  | Tiling c -> handle_tiling wm seat c
;;
