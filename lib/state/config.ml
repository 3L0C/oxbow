open! Ocdwm_core
open! Ocdwm_layout
include Types.Config

let default_tiling () =
  Params.Tiling.{ scheme = Even; mfact = 0.55; nmaster = 1; dir = Left }
;;

let default_scrolling () =
  Params.Scrolling.
    { policy = Visible; default_width = Width_fac.of_float 0.55; offset = 0 }
;;

let default_gaps () = Params.Gaps.{ inner = 10; outer = 20 }

let default_borders =
  Border.
    { width = 4l
    ; focused_color = Color.of_string_exn "#7FB4CA"
    ; unfocused_color = Color.of_string_exn "#727169"
    ; urgent_color = Color.of_string_exn "#FF5D62"
    }
;;

let create_tag_data () =
  Data.
    { layout = Tiling
    ; tiling = default_tiling ()
    ; scrolling = default_scrolling ()
    ; gaps = default_gaps ()
    }
;;

let default () =
  { default_tag_config = create_tag_data ()
  ; borders = default_borders
  ; cursor_theme = None
  ; modkey = Wire.Modifiers.mod4
  ; rules = { window = []; input = [] }
  ; modes = [ Mode.normal; Mode.locked ]
  ; focus_follows_pointer = true
  ; warp_on_focus = false
  ; repeat_rate = 50
  ; repeat_delay = 250
  }
;;

let set_focus_follows_pointer (wm : Types.Wm.t) focus_follows_pointer =
  wm.config.focus_follows_pointer <- focus_follows_pointer
;;

let set_warp_on_focus (wm : Types.Wm.t) warp_on_focus =
  wm.config.warp_on_focus <- warp_on_focus
;;

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
  | Urgent -> wm.config.borders.urgent_color <- color
  | Focused -> wm.config.borders.focused_color <- color
  | Unfocused -> wm.config.borders.unfocused_color <- color
;;

let set_default_width (td : Data.t) ~(delta : float Delta.t) =
  let f =
    Delta.resolve
      ~add:( +. )
      ~current:(Width_fac.to_float td.scrolling.default_width)
      delta
  in
  td.scrolling.default_width <- Width_fac.of_float f
;;

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
        { policy = td.scrolling.policy
        ; default_width = td.scrolling.default_width
        ; offset = td.scrolling.offset
        }
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
          if Pattern.equal rule.pattern r.pattern then rule else r)
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
