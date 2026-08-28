let input =
  [ [ "oxctl"; "gaps"; "inner"; "10" ]
  ; [ "oxctl"; "gaps"; "outer"; "20" ]
  ; [ "oxctl"; "border"; "width"; "4" ]
  ; [ "oxctl"; "border"; "color"; "focused"; "'#7fb4ca'" ]
  ; [ "oxctl"; "border"; "color"; "unfocused"; "'#727169'" ]
  ; [ "oxctl"; "border"; "color"; "urgent"; "'#ff5d62'" ]
  ; [ "oxctl"; "input"; "pointer"; "follow"; "not-scrolling" ]
  ; [ "oxctl"; "input"; "pointer"; "warp"; "on" ]
  ; [ "oxctl"; "input"; "keyboard"; "repeat"; "50"; "250" ]
  ; [ "oxctl"; "input"; "cursor"; "theme"; "'BreezeX-RosePineDawn-Linux'"; "24" ]
  ; [ "oxctl"; "output"; "column"; "width"; "0.95" ]
  ; [ "oxctl"; "layout"; "tiling"; "nmaster"; "1" ]
  ; [ "oxctl"; "layout"; "tiling"; "mfact"; "0.60" ]
  ; [ "oxctl"; "layout"; "scrolling"; "align"; "visible"; "--all" ]
  ; [ "oxctl"; "layout"; "scrolling"; "default-width"; "--all"; "0.95" ]
  ; [ "oxctl"; "layout"; "scrolling"; "--output"; "DP-3" ]
  ; [ "oxctl"; "bind"; "window"; "column"; "default"; "to"; "Super+a" ]
  ; [ "oxctl"; "bind"; "window"; "column"; "consume"; "to"; "Super+c" ]
  ; [ "oxctl"; "bind"; "window"; "column"; "release"; "to"; "Super+x" ]
  ; [ "oxctl"; "bind"; "window"; "column"; "cycle"; "to"; "Super+d" ]
  ; [ "oxctl"; "bind"; "layout"; "scrolling"; "centered"; "to"; "Super+f" ]
  ; [ "oxctl"; "bind"; "layout"; "scrolling"; "visible"; "to"; "Super+p" ]
  ; [ "oxctl"; "bind"; "layout"; "scrolling"; "left"; "to"; "Super+b" ]
  ; [ "oxctl"; "bind"; "window"; "toggle"; "floating"; "to"; "Super+Shift+space" ]
  ; [ "oxctl"; "bind"; "window"; "toggle"; "fake-fullscreen"; "to"; "Super+Shift+i" ]
  ; [ "oxctl"; "bind"; "window"; "toggle"; "maximize"; "to"; "Super+Shift+f" ]
  ; [ "oxctl"; "bind"; "window"; "toggle"; "sticky"; "occupied"; "to"; "Super+Shift+s" ]
  ; [ "oxctl"; "bind"; "window"; "toggle"; "swallow"; "to"; "Super+w" ]
  ; [ "oxctl"; "bind"; "tag"; "toggle"; "1"; "to"; "Super+Shift+1" ]
  ; [ "oxctl"; "bind"; "tag"; "toggle"; "2"; "to"; "Super+Shift+2" ]
  ; [ "oxctl"; "bind"; "tag"; "toggle"; "3"; "to"; "Super+Shift+3" ]
  ; [ "oxctl"; "bind"; "tag"; "toggle"; "4"; "to"; "Super+Shift+4" ]
  ; [ "oxctl"; "bind"; "tag"; "toggle"; "5"; "to"; "Super+Shift+5" ]
  ; [ "oxctl"; "bind"; "tag"; "toggle"; "6"; "to"; "Super+Shift+6" ]
  ; [ "oxctl"; "bind"; "tag"; "toggle"; "7"; "to"; "Super+Shift+7" ]
  ; [ "oxctl"; "bind"; "tag"; "toggle"; "8"; "to"; "Super+Shift+8" ]
  ; [ "oxctl"; "bind"; "tag"; "toggle"; "9"; "to"; "Super+Shift+9" ]
  ; [ "oxctl"
    ; "window"
    ; "rules"
    ; "add"
    ; "--app-id=kitten-scratch"
    ; "--scratchpad=kitten-scratch"
    ; "--move-to=25%,25%"
    ; "--resize-to=50%,50%"
    ]
  ; [ "oxctl"
    ; "window"
    ; "rules"
    ; "add"
    ; "--app-id=kitten-scratch"
    ; "--scratchpad=kitten-scratch"
    ; "--move-to"
    ; "25%,-25%"
    ; "--resize-to"
    ; "-50%,50%"
    ]
  ; [ "oxctl"
    ; "window"
    ; "rules"
    ; "add"
    ; "--app-id=kitten-scratch"
    ; "--scratchpad=kitten-scratch"
    ; "--move-to"
    ; "-25,25"
    ; "--resize-to"
    ; "50,-50"
    ]
  ; [ "oxctl"
    ; "bind"
    ; "spawn"
    ; "'oxctl scratchpad toggle kitten-scratch || kitty --app-id=kitten-scratch -o \
       font_size=24'"
    ; "to"
    ; "Super+Shift+Return"
    ]
  ; [ "oxctl"
    ; "bind"
    ; "output"
    ; "overview"
    ; "cycle"
    ; "next"
    ; "--until-release=Super"
    ; "to"
    ; "Super+n"
    ]
  ; [ "oxctl"
    ; "bind"
    ; "output"
    ; "overview"
    ; "cycle"
    ; "prev"
    ; "--until-release=Super"
    ; "to"
    ; "Super+Shift+n"
    ]
  ; [ "oxctl"
    ; "bind"
    ; "output"
    ; "swap"
    ; "tags"
    ; "--ring"
    ; "HDMI-A-1,DP-3,DP-1"
    ; "--rev"
    ; "to"
    ; "Shift+Control+Alt+space"
    ]
  ; [ "oxctl"
    ; "bind"
    ; "output"
    ; "swap"
    ; "tags"
    ; "--ring"
    ; "HDMI-A-1,DP-3,DP-1"
    ; "to"
    ; "Shift+Control+Alt+parenright"
    ]
  ; [ "oxctl"
    ; "bind"
    ; "output"
    ; "swap"
    ; "tags"
    ; "--ring"
    ; "HDMI-A-1,DP-3,DP-1"
    ; "to"
    ; "Shift+Control+Alt+j"
    ]
  ; [ "oxctl"
    ; "bind"
    ; "output"
    ; "swap"
    ; "tags"
    ; "--ring"
    ; "HDMI-A-1,DP-3,DP-1"
    ; "--rev"
    ; "to"
    ; "Shift+Control+Alt+k"
    ]
  ; [ "oxctl"; "bind"; "window"; "tag"; "set"; "1"; "to"; "Super+Control+1" ]
  ; [ "oxctl"; "bind"; "window"; "tag"; "set"; "2"; "to"; "Super+Control+2" ]
  ; [ "oxctl"; "bind"; "window"; "tag"; "set"; "3"; "to"; "Super+Control+3" ]
  ; [ "oxctl"; "bind"; "window"; "tag"; "set"; "4"; "to"; "Super+Control+4" ]
  ; [ "oxctl"; "bind"; "window"; "tag"; "set"; "5"; "to"; "Super+Control+5" ]
  ; [ "oxctl"; "bind"; "window"; "tag"; "set"; "6"; "to"; "Super+Control+6" ]
  ; [ "oxctl"; "bind"; "window"; "tag"; "set"; "7"; "to"; "Super+Control+7" ]
  ; [ "oxctl"; "bind"; "window"; "tag"; "set"; "8"; "to"; "Super+Control+8" ]
  ; [ "oxctl"; "bind"; "window"; "tag"; "set"; "9"; "to"; "Super+Control+9" ]
  ; [ "oxctl"; "window"; "rules"; "add"; "--tags"; "3"; "--app-id=firefox" ]
  ; [ "oxctl"; "window"; "rules"; "add"; "--tags"; "2"; "--app-id=emacs" ]
  ; [ "oxctl"
    ; "window"
    ; "rules"
    ; "add"
    ; "--tags"
    ; "9"
    ; "--app-id=org.keepassxc.KeePassXC"
    ]
  ; [ "oxctl"; "window"; "rules"; "add"; "--tags"; "4"; "--app-id=vesktop" ]
  ; [ "oxctl"; "window"; "rules"; "add"; "--tags"; "4"; "--app-id=steam" ]
  ; [ "oxctl"; "window"; "rules"; "add"; "--swallow=terminal"; "--app-id=kitty" ]
  ; [ "oxctl"
    ; "window"
    ; "rules"
    ; "add"
    ; "--title=Picture-in-Picture"
    ; "--spawn-position=end"
    ; "--spawn-focus=disabled"
    ; "--resize-to=35%,35%"
    ; "--move-to=64%,62%"
    ; "--sticky=occupied"
    ]
  ; [ "oxctl"; "keymap"; "mode"; "declare"; "passthrough" ]
  ; [ "oxctl"; "bind"; "keymap"; "mode"; "enter"; "passthrough"; "to"; "Super+F1" ]
  ; [ "oxctl"
    ; "bind"
    ; "keymap"
    ; "mode"
    ; "enter"
    ; "--mode=passthrough"
    ; "normal"
    ; "to"
    ; "Super+F1"
    ]
  ; [ "oxctl"; "bind"; "session"; "exit"; "to"; "Super+Shift+q" ]
  ; [ "oxctl"
    ; "bind"
    ; "output"
    ; "focus"
    ; "match"
    ; "--name=^HDMI-A-1$"
    ; "to"
    ; "Shift+Control+Alt+m"
    ]
  ; [ "oxctl"
    ; "bind"
    ; "output"
    ; "focus"
    ; "match"
    ; "--name=^DP-3$"
    ; "to"
    ; "Shift+Control+Alt+n"
    ]
  ; [ "oxctl"
    ; "bind"
    ; "output"
    ; "focus"
    ; "match"
    ; "--name=^DP-1$"
    ; "to"
    ; "Shift+Control+Alt+e"
    ]
  ; [ "oxctl"; "bind"; "window"; "send"; "next"; "--take"; "to"; "Shift+Control+Alt+l" ]
  ; [ "oxctl"; "bind"; "window"; "send"; "prev"; "--take"; "to"; "Shift+Control+Alt+h" ]
  ; [ "oxctl"
    ; "bind"
    ; "window"
    ; "tag"
    ; "shift"
    ; "next"
    ; "--occupied"
    ; "to"
    ; "Super+Shift+l"
    ]
  ; [ "oxctl"
    ; "bind"
    ; "window"
    ; "tag"
    ; "shift"
    ; "prev"
    ; "--occupied"
    ; "to"
    ; "Super+Shift+h"
    ]
  ; [ "oxctl"
    ; "bind"
    ; "window"
    ; "tag"
    ; "shift"
    ; "next"
    ; "--follow"
    ; "to"
    ; "Super+Control+l"
    ]
  ; [ "oxctl"
    ; "bind"
    ; "window"
    ; "tag"
    ; "shift"
    ; "prev"
    ; "--follow"
    ; "to"
    ; "Super+Control+h"
    ]
  ; [ "oxctl"
    ; "bind"
    ; "spawn"
    ; "'oxctl window resize to 35% 35% && oxctl window move to 64% 62%'"
    ; "to"
    ; "Super+z"
    ]
  ; [ "oxctl"; "bind"; "layout"; "tiling"; "mfact"; "-0.05"; "to"; "Super+Control+h" ]
  ; [ "oxctl"; "bind"; "layout"; "tiling"; "mfact"; "+0.05"; "to"; "Super+Control+h" ]
  ; [ "oxctl"; "bind"; "layout"; "tiling"; "mfact"; "0.05"; "to"; "Super+Control+h" ]
  ; [ "oxctl"; "bind"; "layout"; "tiling"; "mfact"; "0.05"; "to"; "Super+Control+h" ]
  ; [ "oxctl"; "bind"; "window"; "move"; "down"; "-10%"; "to"; "Super+Shift+up" ]
  ; [ "oxctl"; "bind"; "window"; "move"; "down"; "+5%"; "to"; "Super+Shift+up" ]
  ; [ "oxctl"
    ; "bind"
    ; "layout"
    ; "tiling"
    ; "mfact"
    ; "--"
    ; "-0.05"
    ; "to"
    ; "Super+Control+h"
    ]
  ; [ "oxctl"
    ; "bind"
    ; "layout"
    ; "tiling"
    ; "mfact"
    ; "--"
    ; "+0.05"
    ; "to"
    ; "Super+Control+h"
    ]
  ; [ "oxctl"
    ; "bind"
    ; "layout"
    ; "tiling"
    ; "mfact"
    ; "--"
    ; "0.05"
    ; "to"
    ; "Super+Control+h"
    ]
  ; [ "oxctl"
    ; "bind"
    ; "layout"
    ; "tiling"
    ; "mfact"
    ; "--"
    ; "0.05"
    ; "to"
    ; "Super+Control+h"
    ]
  ; [ "oxctl"; "bind"; "window"; "move"; "down"; "--"; "-10%"; "to"; "Super+Shift+up" ]
  ; [ "oxctl"; "bind"; "window"; "move"; "down"; "--"; "+5%"; "to"; "Super+Shift+up" ]
  ]
;;

let check_preparse_args () =
  let print_list ppf l = String.concat " " l |> Printf.printf ppf in
  let preparse_args args =
    let args' = Oxbow_ctl.Ctl_cli.preparse_args args in
    print_list "args : %S\n" args;
    print_list "args': %S\n" args';
    Printf.printf "args = args': %s\n\n" (if args = args' then "true" else "false")
  in
  List.iter preparse_args input
;;

let () = check_preparse_args ()
