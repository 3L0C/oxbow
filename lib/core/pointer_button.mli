type t =
  | Key_unknown
  | Btn_0
  | Btn_1
  | Btn_2
  | Btn_3
  | Btn_4
  | Btn_5
  | Btn_6
  | Btn_7
  | Btn_8
  | Btn_9
  | Btn_left
  | Btn_right
  | Btn_middle
  | Btn_side
  | Btn_extra
  | Btn_forward
  | Btn_back
  | Btn_task

(** [all] is the list of all pointer buttons, excluding [Key_unknown]. *)
val all : t list

(** [of_string s] is the button whose constructor name is [s] (["Btn_left"]);
    [Error msg] when unrecognized. *)
val of_string : string -> (t, string) result

(** [to_string b] is [b]'s constructor name. *)
val to_string : t -> string

(** [of_int32 code] is the button for Linux input-event [code]; [Key_unknown]
    for any code outside [0x100]-[0x117]. *)
val of_int32 : int32 -> t

(** [to_int32 b] is [b]'s Linux input-event code; [Key_unknown] is [KEY_UNKNOWN]
    ([240l]). *)
val to_int32 : t -> int32

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
