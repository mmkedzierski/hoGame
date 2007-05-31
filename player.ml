(** Modul kontrolujacy, kto (czlowiek czy komputer) w danej chwili wykonuje ruch
    oraz odpowiedzialny za sztuczna inteligencje.
    @author Marian Marek Kedzierski *)
  

(** {1 typy} *)

(** typ rodzaju uzytkownika *)
type user = Human | Computer | No_user;;


  
  
(** {1 stale} *)

(** stala czasowa w milisekundach okreslajaca przerwy pomiedzy 
    kolejnymi ruchami komputera *)
let hesitate_time = 50;;




(** {1 zmienne globalne} *)

(** zmienna okreslajaca, kim jest bialy gracz *)
let white_user = ref No_user;;

(** zmienna okreslajaca, kim jest czarny gracz *)
let black_user = ref No_user;;




(** {1 selektory} *)

(** funkcja okreslajaca, czy dany gracz jest czlowiekiem *)
let is_human = function
  | Structs.White -> !white_user = Human
  | Structs.Black -> !black_user = Human
;;


(** funkcja okreslajaca, czy dany gracz jest komputerem *)
let is_computer = function
  | Structs.White -> !white_user = Computer
  | Structs.Black -> !black_user = Computer
;;


(** funkcja okreslajaca, czy teraz ruch nalezy do czlowieka *)
let human_is_moving st =
  let player = Structs.get_player st in
  is_human player
;;


(** funkcja okreslajaca, czy teraz ruch nalezy do komputera *)
let computer_is_moving st =
  let player = Structs.get_player st in
  is_computer player
;;




(** {1 funkcje pomocnicze} *)

(** funkcja zwracajaca losowy element listy *)
let random_element lst =
  let n = List.length lst in
  assert (n > 0);
  let k = Random.int n in 
  List.nth lst k
;;




(** {1 funkcje znajdujace ruchy} *)

(** funkcja znajdujaca losowy ruch dla zadanego stanu gry w imieniu komputera*)
let random_move st =
  assert (is_computer (Structs.get_player st));
  let lst = Structs.non_empty st in
  Structs.construct_move (random_element lst);
;;


(** funkcja znajdujaca ruch dla zadanego stanu gry w imieniu komputera (AI) 
    {i idea sztucznej inteligencji: na planszy wybieramy nastepujacy podzbior
    pol "specjalnych": sa to pola parzyste w rzedach nieparzystych oraz 
    wszystkie pola w rzedach parzystych. Kamien jest stawiany na pierwszym
    wolnym polu specjalnym lub jesli takich nie ma to w losowym miejscu.
    Ponadto nigdy nie stawiamy pola w oku ktoregokolwiek z graczy ani w polu,
    ktorego zajecie spowodowaloby uduszenie wlasnej grupy (scislej mowiac:
    ruch musi zwiekszyc liczbe posiadanych kamieni). } *)
let wise_move st =
  (* zmienne i stale pomocnicze *)
  let player = Structs.get_player st in
  let fld = ref (0, 0) in
  let non_empty = Structs.non_empty st in

  (* funkcje pomocnicze *)
  let special_field (x, y) = x mod 2 = 1 && y mod 2 = 0  ||  x mod 2 = 0 in
  let not_eye (x, y) = 
    not (Structs.is_eye st (x, y) Structs.White) &&
    not (Structs.is_eye st (x, y) Structs.Black) in
  let not_suicide (x, y) =
    let mv = Structs.construct_move (x, y) in
    let st2 = Structs.make_move st mv in
    Rules.compute_score st2 player > Rules.compute_score st player in
  let not_prohibited (x, y) = not_eye (x, y) && not_suicide (x, y) in
    
  (* znalezienie pierwszego pola specjalnego ktore nie jest okiem *)
  let f (x, y) = special_field (x, y) && not_prohibited (x, y) in begin
    fld := try List.find f non_empty with Not_found -> (0, 0);
  end;
  
  (* jesli nie ma juz zadnego takiego to wybieramy losowe, 
     ktore nie jest okiem *)
  if !fld = (0, 0) then begin
    let lst = List.filter not_prohibited non_empty in
    if lst <> [] then fld := random_element lst;
  end;
  
  (* zwrocenie wyniku *)
  match !fld with
  | (0, 0) -> Structs.pass
  | (x, y) -> Structs.construct_move (x, y)
;;


(** funkcja pusta, ktora nigdy nie powinna byc wywolana *)
let no_move st = failwith "Proba wywolania funkcji no_move";;
