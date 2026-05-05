open Types

type manage
type render
type 'p t = { wm : Window_manager_t.t }

let wm c = c.wm
let with_manage wm f = f { wm }
let with_render wm f = f { wm }
