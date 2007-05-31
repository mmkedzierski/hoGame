(** Modul odpowiedzialny za skladniki menu w interfejsie.
    @author Marian Marek Kedzierski *)
    
(** {1 funkcje odpowiedzialne za skladniki menu} *)

(** funkcja tworzaca okno dialogowe "Nowa gra" *)
val new_game : unit -> unit;;

(** funkcja pokazujaca zasady gry *)
val show_rules : unit -> unit;;

(** funkcja pokazujaca instrukcje do gry *)
val instruction : unit -> unit;;

(** funkcja pokazujaca informacje o programie *)
val about_program : unit -> unit;;




(** {1 skladniki menu} *)

(** lista elementow menu "Gra" *)
val game_entries : [> `I of string * (unit -> unit) | `S] list;;

(** lista elementow menu "Pomoc" *)
val help_entries : [> `I of string * (unit -> unit) | `S] list;;




(** {1 funkcja glowna modulu: tworzaca menu gry (czesc interfejsu)} *)

(** funkcja tworzaca menu gry (czesc interfejsu) *)
val create_menu : packing:(GObj.widget -> unit) -> unit;;
