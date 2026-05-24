exception Unavailable
exception Finished

let unavailable () = raise Unavailable
let finished () = raise Finished
