(** Modul odpowiedzialny za stworzenie ramowego interfejsu programu
    (polaczenie wszystkich jego elementow skladowych).
    @author Marian Marek Kedzierski *)

(** Funkcja uaktualniajaca wszystkie wyswietlane dane tekstowe *)
val update_text_info : Structs.state -> unit;;

(** Funkcja uaktualniajaca wszystkie wyswietlane informacje
    (lacznie z arena gry) *)
val update_displayed_info : Structs.state -> unit;;

(** {1 glowna funkcja modulu} *)

(** stworzenie ramowego interfejsu programu *)
val build_interface : unit -> unit;;
