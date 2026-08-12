open! Oxbow_core
open! Oxbow_layout
include Types.Config

let default_tiling () =
  Params.Tiling.{ scheme = Even; mfact = 0.55; nmaster = 1; dir = Left }
;;

let default_scrolling () =
  Params.Scrolling.
    { align = Visible; default_width = Width_fac.of_float 0.5; offset = 0; dir = Left }
;;

let default_floating () = Params.Floating.{ seed = Pct 50. }
let default_gaps () = Params.Gaps.{ inner = 10; outer = 20 }

let default_borders =
  Border.
    { width = 4l
    ; focused = Color.of_string_exn "#7FB4CA"
    ; unfocused = Color.of_string_exn "#727169"
    ; urgent = Color.of_string_exn "#FF5D62"
    ; swallowing = Color.of_string_exn "#98BB6C"
    ; captured = Color.of_string_exn "#957FB8"
    }
;;

let create_tag_data () =
  Data.
    { layout = Tiling
    ; tiling = default_tiling ()
    ; scrolling = default_scrolling ()
    ; floating = default_floating ()
    ; gaps = default_gaps ()
    }
;;

let default () =
  { default_tag_config = create_tag_data ()
  ; borders = default_borders
  ; cursor_theme = None
  ; modkey = Wire.Modifiers.mod4
  ; rules = { window = []; input = [] }
  ; spawn = { position = Master; focus = true }
  ; modes = [ Mode.normal; Mode.locked ]
  ; focus_follows_pointer = Not_scrolling
  ; warp_on_focus = false
  ; drag_retile = false
  ; repeat_rate = 50
  ; repeat_delay = 250
  }
;;

let set_focus_follows_pointer (wm : Types.Wm.t) policy =
  wm.config.focus_follows_pointer <- policy
;;

let set_warp_on_focus (wm : Types.Wm.t) warp_on_focus =
  wm.config.warp_on_focus <- warp_on_focus
;;

let set_drag_retile (wm : Types.Wm.t) b = wm.config.drag_retile <- b

let set_border_width (wm : Types.Wm.t) width =
  if width < 0l
  then Error "border width cannot be negative"
  else (
    wm.config.borders.width <- width;
    Schedule.manage ();
    Ok None)
;;

let set_cursor_theme (wm : Types.Wm.t) cursor_theme =
  wm.config.cursor_theme <- cursor_theme
;;

let set_key_repeat (wm : Types.Wm.t) ~rate ~delay =
  wm.config.repeat_rate <- rate;
  wm.config.repeat_delay <- delay
;;

let set_border_color (wm : Types.Wm.t) (border : Border_target.t) color =
  Schedule.manage ();
  match border with
  | Urgent -> wm.config.borders.urgent <- color
  | Focused -> wm.config.borders.focused <- color
  | Unfocused -> wm.config.borders.unfocused <- color
  | Swallowing -> wm.config.borders.swallowing <- color
  | Captured -> wm.config.borders.captured <- color
;;

let set_default_width (td : Data.t) ~delta =
  let f =
    Delta.resolve
      ~add:( +. )
      ~current:(Width_fac.to_float td.scrolling.default_width)
      delta
  in
  td.scrolling.default_width <- Width_fac.of_float f
;;

let set_float_seed (td : Data.t) ~seed = td.floating.seed <- seed
let set_spawn_position (wm : Types.Wm.t) position = wm.config.spawn.position <- position
let set_spawn_focus (wm : Types.Wm.t) b = wm.config.spawn.focus <- b

let copy_tag_data (td : Data.t) =
  Data.
    { layout = td.layout
    ; tiling =
        { scheme = td.tiling.scheme
        ; mfact = td.tiling.mfact
        ; nmaster = td.tiling.nmaster
        ; dir = td.tiling.dir
        }
    ; scrolling =
        { align = td.scrolling.align
        ; default_width = td.scrolling.default_width
        ; offset = td.scrolling.offset
        ; dir = td.scrolling.dir
        }
    ; floating = { seed = td.floating.seed }
    ; gaps = { inner = td.gaps.inner; outer = td.gaps.outer }
    }
;;

let add_window_rule (wm : Types.Wm.t) rule =
  wm.config.rules.window <- wm.config.rules.window @ [ rule ]
;;

let remove_window_rule (wm : Types.Wm.t) index =
  wm.config.rules.window <- List.filteri (fun i _ -> i <> index) wm.config.rules.window
;;

let replace_window_rule (wm : Types.Wm.t) (rule : Window_rule.t) =
  wm.config.rules.window
  <- List.map
       (fun (r : Window_rule.t) ->
          if Window_pattern.equal rule.pattern r.pattern then rule else r)
       wm.config.rules.window
;;

let add_input_rule (wm : Types.Wm.t) rule =
  wm.config.rules.input <- wm.config.rules.input @ [ rule ]
;;

let remove_input_rule (wm : Types.Wm.t) index =
  wm.config.rules.input <- List.filteri (fun i _ -> i <> index) wm.config.rules.input
;;

let replace_input_rule (wm : Types.Wm.t) (rule : Input_rule.t) =
  wm.config.rules.input
  <- List.map
       (fun (r : Input_rule.t) -> if Input_rule.equal r rule then rule else r)
       wm.config.rules.input
;;

let declare_mode (wm : Types.Wm.t) name = wm.config.modes <- wm.config.modes @ [ name ]
