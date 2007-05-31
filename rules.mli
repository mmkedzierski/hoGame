(** Modul odpowiedzialny za zasady gry 
    @author Marian Marek Kedzierski *)

(** {1 wyjatki} *)

(** podnoszony przy zazadaniu niedozwolonego rozmiaru planszy *)
exception Invalid_board_size of int;;




(** {1 stale} *)

(** minimalny rozmiar planszy *)
val min_board_size : int;;

(** maksymalny rozmiar planszy *)
val max_board_size : int;;

(** roznica pomiedzy kolejnymi dozwolonymi rozmiarami planszy *)
val board_size_step : int;;

(** domyslny rozmiar planszy *)
val default_board_size : int;;

(** minimalna wartosc "komi" *)
val min_komi : float;;

(** maksymalna wartosc "komi" *)
val max_komi : float;;

(** roznica pomiedzy kolejnymi wybieralnymi wartosciami "komi" *)
val komi_step: float;;

(** domyslna wartosc "komi" *)
val default_komi: float;;

(** minimalny limit ruchow *)
val min_moves_limit : int;;

(** maksymalny limit ruchow *)
val max_moves_limit : int;;

(** roznica pomiedzy kolejnymi wybieralnymi limitami ruchow *)
val moves_limit_step : int;;




(** {1 pozostale funkcje} *)

(** funkcja oblicza na podstawie wielkosci planszy standardowy 
    gorny limit ruchow *)
val standard_moves_limit : int -> int;; 
 
(** funkcja obliczajaca punkty w danej konfiguracji *)
val compute_score : Structs.state -> Structs.player_t -> float;;

(** funkcja sprawdza, czy dany rozmiar planszy jest dozwolony *)
val is_board_size_valid : int -> bool;;

(** funkcja sprawdzajaca, czy zadana konfiguracja gry jest legalna *)
val legal_state : Structs.state -> bool;;

(** funkcja sprawdzajaca, czy zadany ruch jest legalny *)
val legal_move : Structs.state -> Structs.move -> bool;;

(** funkcja sprawdzajaca, czy gra sie juz skonczyla *)
val finished : Structs.state -> bool;;
