exception Finished
exception Unavailable

let finished () = raise Finished
let unavailable () = raise Unavailable
