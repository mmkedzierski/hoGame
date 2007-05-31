(** Modul odpowiedzialny za zarzadzanie przebiegiem gry
    @author Marian Marek Kedzierski *)

(** {1 zmienne globalne } *)

(** czy gra trwa obecnie (lub ewentualnie jest wstrzymana)? *)
val game_is_active : bool ref;;

(** czy gra trwa i nie jest wstrzymana? *)
val game_is_running : bool ref;;

(** czy w tej chwili wyswietlany jest wynik skonczonej gry? *)
val showing_score : bool ref;;

(** jaki jest aktualny stan gry *)
val current_state : Structs.state ref;;




(** {1 stale} *)

(** czas w milisekundach pomiedzy kolejnymi wywolaniami funkcji
    kontrolujacej stan gry *)
val control_time : int;;




(** {1 referencje do funkcji (uzywane do wplywania na wewnetrzna strukture 
    wyzszych modulow) } *)

(** referencja do funkcji uaktualniajacej wyswietlane na ekranie dane 
    o aktualnym stanie gry (z wyjatkiem areny gry).
    Nadpisywana przez modul glowny [Ho]. *)
val update_displayed_info : (Structs.state -> unit) ref;;

(** referencja do funkcji uaktualniajacej tylko pasek stanu *)
val update_text_info : (Structs.state -> unit) ref;;

(** referencja do funkcji przygotowujacej arene do rozgrywki. 
    Nadpisywana przez modul glowny [Ho]. *)
val prepare_arena : (size:int -> unit) ref;;

(** referencja do funkcji czyszczacej arene po rozgrywce. 
    Nadpisywana przez modul glowny [Ho]. *)
val clear_arena : (unit -> unit) ref;;

(** referencja do funkcji wykonujacej ruch w imieniu gracza czarnego.
    Nadpisywana przez funkcje [Interface.new_game] *)
val black_make_move : (Structs.state -> Structs.move) ref;;

(** referencja do funkcji wykonujacej ruch w imieniu gracza bialego
    Nadpisywana przez funkcje [Interface.new_game] *)
val white_make_move : (Structs.state -> Structs.move) ref;;

(** referencja do funkcji wyswietlajacej okno dialogowe z informacja.
    Nadpisywana przez modul glowny programu [Ho].
    @param title Tytul okienka dialogowego
    @param text Tekst do wyświetlenia *)
val view_information : (title:string -> text:string -> unit -> unit) ref;;




(** {1 funkcje zarzadzajace gra} *)

(** funkcja wykonujaca ruch niepasujacy (w imieniu czlowieka) *)
val make_move : int * int -> unit;;

(** funkcja pasujaca w imieniu aktywnego gracza *)
val do_pass : unit -> unit;;

(** funkcja wykonujaca ruch w imieniu komputera (wywolywana okresowo
    przez petle glowna programu). Zwraca true (na znak, ze chce byc
    nadal wywolywana) *)
val computer_make_move : unit -> bool;;

(** funkcja cofajaca ruchy *)
val cancel_move : unit -> unit;;

(** funkcja zawieszajaca gre *)
val pause : unit -> unit;;

(** funkcja wznawiajaca gre *)
val resume : unit -> unit;;

(** funkcja konczaca aktualna gre i informujaca o wyniku, ale nie wymazujaca
    wyswietlanych informacji *)
val end_game : unit -> unit;;

(** funkcja sprawdzajaca, czy gra przypadkiem juz sie nie skonczyla *)
val check_if_finished : unit -> bool;;

(** funkcja rozpoczynajaca gre *)
val start : board_size:int -> komi:float -> moves_limit:int -> unit;;

(** funkcja wychodzaca z aktualnej gry (sprzatajaca po niej) *)
val quit : unit -> unit;;
