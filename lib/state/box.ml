type 'a t = { mutable body : 'a option }

let fill box body = box.body <- Some body
let clear box = box.body <- None
