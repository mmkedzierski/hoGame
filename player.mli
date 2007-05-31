(** Modul kontrolujacy, kto (czlowiek czy komputer) w danej chwili wykonuje ruch
    oraz odpowiedzialny za sztuczna inteligencje.
    @author Marian Marek Kedzierski *)
  
(** {1 typy} *)

(** typ rodzaju uzytkownika *)
type user = Human | Computer | No_user;;


  
  
(** {1 stale} *)

(** stala czasowa w milisekundach okreslajaca przerwy pomiedzy 
    kolejnymi ruchami komputera *)
val hesitate_time : int;;




(** {1 zmienne globalne} *)

(** zmienna okreslajaca, kim jest bialy gracz *)
val white_user : user ref;;

(** zmienna okreslajaca, kim jest czarny gracz *)
val black_user : user ref;;




(** {1 selektory} *)

(** funkcja okreslajaca, czy dany gracz jest czlowiekiem *)
val is_human : Structs.player_t -> bool;;

(** funkcja okreslajaca, czy dany gracz jest komputerem *)
val is_computer : Structs.player_t -> bool;;

(** funkcja okreslajaca, czy teraz ruch nalezy do czlowieka *)
val human_is_moving : Structs.state -> bool;;

(** funkcja okreslajaca, czy teraz ruch nalezy do komputera *)
val computer_is_moving : Structs.state -> bool;;




(** {1 funkcje znajdujace ruchy} *)

(** funkcja znajdujaca losowy ruch dla zadanego stanu gry w imieniu komputera*)
val random_move : Structs.state -> Structs.move;;

(** funkcja znajdujaca ruch dla zadanego stanu gry w imieniu komputera (AI) *)
val wise_move : Structs.state -> Structs.move;;

(** funkcja pusta, ktora nigdy nie powinna byc wywolana *)
val no_move : Structs.state -> Structs.move;;
