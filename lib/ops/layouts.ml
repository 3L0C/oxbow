open! Oxbow_ipc

let handle_scrolling wm seat (cmd : Command.Layout.Scrolling.t) =
  match cmd with
  | Select { align; scope } -> Arrange.select_scrolling_alignment wm seat align scope
  | Align { align; scope } -> Arrange.set_scrolling_alignment wm seat align scope
  | Default_width { delta; scope } -> Arrange.set_default_width wm seat delta scope
  | Orientation { dir; scope } -> Arrange.set_scrolling_orientation wm seat dir scope
;;

let handle_tiling wm seat (cmd : Command.Layout.Tiling.t) =
  match cmd with
  | Cycle dir -> Arrange.cycle_scheme wm seat dir
  | Mfact { delta; scope } -> Arrange.set_mfact wm seat delta scope
  | Nmaster { delta; scope } -> Arrange.set_nmaster wm seat delta scope
  | Orientation { dir; scope } -> Arrange.set_tiling_orientation wm seat dir scope
  | Select { scheme; scope } -> Arrange.select_tiling_scheme wm seat scheme scope
  | Scheme { scheme; scope } -> Arrange.set_tiling_scheme wm seat scheme scope
;;

let handle_floating wm seat (cmd : Command.Layout.Floating.t) =
  match cmd with
  | Seed { seed; scope } -> Arrange.set_float_seed wm seat seed scope
;;

let handle wm seat (cmd : Command.Layout.t) =
  match cmd with
  | Cycle dir -> Arrange.cycle_layout wm seat dir
  | Select { layout; scope } -> Arrange.set_layout wm seat layout scope
  | Scrolling c -> handle_scrolling wm seat c
  | Tiling c -> handle_tiling wm seat c
  | Floating c -> handle_floating wm seat c
;;
