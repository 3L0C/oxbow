let src = Logs.Src.create "oxbow.state" ~doc:"oxbow state library"

include (val Logs.src_log src : Logs.LOG)
