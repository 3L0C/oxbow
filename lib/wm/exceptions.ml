exception Unavailable
exception Finished
exception Action_failed of string

let unavailable () = raise Unavailable
let finished () = raise Finished
let action_failed s = raise (Action_failed s)
