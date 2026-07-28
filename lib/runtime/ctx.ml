open! Ocdwm_state

type plan = [ `Plan ]
type manage = [ `Manage ]
type render = [ `Render ]
type 'p t = { wm : Wm.t }

let wm c = c.wm
let plan c = { wm = c.wm }
let with_manage wm f = Schedule.with_tick (fun () -> f { wm })
let with_render wm f = f { wm }
