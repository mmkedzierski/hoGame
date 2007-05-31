(** Modul odpowiedzialny za zasady gry 
    @author Marian Marek Kedzierski *)

(** {1 wyjatki} *)

(** podnoszony przy zazadaniu niedozwolonego rozmiaru planszy *)
exception Invalid_board_size of int;;




(** {1 stale} *)

(** minimalny rozmiar planszy *)
let min_board_size = 3;;

(* maksymalny rozmiar planszy *)
let max_board_size = 59;;

(** roznica pomiedzy kolejnymi dozwolonymi rozmiarami planszy *)
let board_size_step = 2;;

(** domyslny rozmiar planszy *)
let default_board_size = 11;;

(** minimalna wartosc "komi" *)
let min_komi = 0.5;;

(** maksymalna wartosc "komi" *)
let max_komi = 99.5;;

(** roznica pomiedzy kolejnymi wybieralnymi wartosciami "komi" *)
let komi_step = 0.5;;

(** domyslna wartosc "komi" *)
let default_komi = 5.5;;

(** minimalny limit ruchow *)
let min_moves_limit = 10;;

(** maksymalny limit ruchow *)
let max_moves_limit = 20000;;

(** roznica pomiedzy kolejnymi wybieralnymi limitami ruchow *)
let moves_limit_step = 5;;




(** {1 funkcje} *)

(** funkcja oblicza na podstawie wielkosci planszy standardowy 
    gorny limit ruchow *)
let standard_moves_limit n = 3 * n * n;;
 

(** funkcja obliczajaca punkty w danej konfiguracji *)
let compute_score st player =
  assert (st <> Structs.unactive_state);
  let res = ref (if player = Structs.White then !Structs.komi else 0.0) in
  
  (* funkcja sprawdzajaca, czy dane pole nalezy do gracza player 
     (bezposrednio lub jako oko) *)
  let my_field (x, y) =
    match Structs.get_field_state st (x, y) with
    (* czy nalezy bezposrednio? *)
    | Structs.Full pl -> player = pl
    (* czy jest okiem? *)
    | Structs.Empty ->
      let pred (x', y') = match Structs.get_field_state st (x', y') with
        | Structs.Empty -> false
        | Structs.Full pl -> pl = player in
      List.for_all pred (Structs.neighbors (x, y)) in
    
  let f (x, y) =
    if my_field (x, y) then res := !res +. 1.0; in
  Structs.iter f;
  !res
;;


(** funkcja sprawdza, czy dany rozmiar planszy jest dozwolony *)
let is_board_size_valid n =
  n mod 2 = 1 && n >= min_board_size && n <= max_board_size
;;


(** funkcja sprawdzajaca, czy zadana konfiguracja gry jest legalna *)
let legal_state st = 
  let flag = ref true in
  let f (x, y) =
    if not (Structs.is_alive st (x, y)) then flag := false; in
  Structs.iter f;
  !flag
;;
  

(** funkcja sprawdzajaca, czy zadany ruch jest legalny *)
let legal_move st mv =
  if mv = Structs.pass then true else
  let (x, y) = Structs.coordinates_of_move mv in
  if not (Structs.in_bounds (x, y)) then false else 
    Structs.get_field_state st (x, y) = Structs.Empty 
;;


(** funkcja sprawdzajaca, czy gra sie juz skonczyla *)
let finished st = 
  assert (Structs.valid_state st);
  Structs.get_passes st >= 2 || Structs.get_moves st > !Structs.moves_limit
;;
