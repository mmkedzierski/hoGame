(** Modul odpowiedzialny za struktury danych potrzebne
    w zarzadzaniu przebiegiem gry.
    @author Marian Marek Kedzierski *)

(** Uwaga: numeracja pol planszy zaczyna sie od 1 *)

(** {1 typy} *)

(** typ gracza *)
type player_t = Black | White;;

(** typ stanu pola planszy *)
type field_state = Empty | Full of player_t;;

(** typ "zdjecia" chwilowego stanu gry (bez pamietania historii) *)
type snapshot;;

(** typ stanu gry *)
type state;;

(** typ ruchu *)
type move;;




(** {1 szczegolne wartosci typow danych} *)

(** stala oznaczajaca ruch pasujacy *)
val pass : move;;

(** stan gry podczas, gdy jest nieaktywna *)
val unactive_state : state;;




(** {1 zmienne globalne } *)

(** aktualny rozmiar planszy *)
val board_size : int ref;;

(** wartosc "komi" *)
val komi : float ref;;

(** gorny limit ruchow w grze *)
val moves_limit : int ref;;




(** {1 referencje do funkcji zdefiniowanych w modulach wyzszego rzedu} *)

(** funkcja obliczajaca punkty w danej konfiguracji 
    Nadpisywana przez modul glowny [Ho]. *)
val compute_score : (state -> player_t -> float) ref;;

(** funkcja sprawdzajaca, czy zadana konfiguracja gry jest legalna
    Nadpisywana przez modul glowny [Ho]. *)
val legal_state : (state -> bool) ref;;





(** {1 funkcje kontrolujace poprawnosc danych} *)

(** funkcja sprawdzajaca poprawnosc stanu gry *)
val valid_state : state -> bool;;




(** {1 funkcje pomocnicze} *)

(** funkcja okresla, czy pole o zadanych wspolrzednych w ukladzie
    wspolrzednych planszy miesci sie na planszy, czy nie *)
val in_bounds: int * int -> bool;;




(** {1 konstruktory} *)

(** funkcja zamieniajaca wspolrzedne pola na ruch oznaczajacy
    postawienie na typ polu pionka *)
val construct_move : int * int -> move;;

(** konstruktor poczatkowego stanu gry *)
val beginning : unit -> state;;




(** {1 iteracje} *)

(** iteracja funkcji danej jako argument po wszystkich polach planszy *)
val iter : (int * int -> unit) -> unit;;




(** {1 selektory} *)

(** funkcja wyluskujaca z ruchu wspolrzedne pola 
    (w przypadku ruchu pasujacego podnosi wyjatek Failure) *)
val coordinates_of_move : move -> int * int;;

(** funkcja zwracajaca liste sasiadow danego pola *)
val neighbors : int * int -> (int * int) list;;

(** funkcja wyluskujaca ze stanu gry aktywnego gracza *)
val get_player : state -> player_t;;

(** funkcja okreslajaca stan danego pola w danej konfiguracji *)
val get_field_state : state -> int * int -> field_state;;

(** funkcja wyluskujaca ze stanu liczbe ostatnich ruchow pasujacych *)
val get_passes : state -> int;;

(** funkcja wyluskujaca ze stanu liczbe wykonanych ruchow *)
val get_moves : state -> int;;

(** funkcja zwracajaca liste elementow grupy danego pola *)
val group : state -> int * int -> (int * int) list;;

(** funkcja sprawdzajaca, czy grupa danego pola ma oddechy *)
val is_alive : state -> int * int -> bool;;

(** funkcja sprawdzajaca, czy dane pole jest okiem danego gracza *)
val is_eye : state -> int * int -> player_t -> bool;;

(** funkcja zwracajaca liste wszystkich niepustych pol *)
val non_empty : state -> (int * int) list;;




(** {1 modyfikatory} *)

(** funkcja zwracajaca przeciwnika *)
val other : player_t -> player_t;;

(** funkcja wykonujaca ruch (przeksztalcajaca stany gry) *)
val make_move : state -> move -> state;;

(** funkcja cofajaca ruch przeksztalcajaca stany gry) *)
val cancel_move : state -> state;;
