(** Modul odpowiedzialny za boczny pasek z przyciskami
    @author Marian Marek Kedzierski *)

(** Funkcja uaktualniajaca wyswietlane dane tekstowe (w pasku przyciskow) *)
val update_text_info : Structs.state -> unit;;

(** funkcja glowna modulu - tworzaca boczny pasek z przyciskami *)
val create_side_bar : packing:(GObj.widget -> unit) -> unit;;
