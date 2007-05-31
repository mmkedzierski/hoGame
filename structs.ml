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
type snapshot = field_state array array;;

(** typ stanu gry - tablica stanow poszczegolnych pol planszy *)
type state = {
  active_player : player_t;
  history : snapshot list; (* stos poprzednich "zdjec" stanu gry *)
  number_of_passes : int;  (* liczba ostatnio wykonanych ruchow pasujacych *)
  number_of_moves : int; (* liczba wykonanych dotychczas ruchow *)
};;

(** typ ruchu - para liczb okreslajaca wspolrzedne punktu, na ktory 
    stawiany jest pionek *)
type move = 
  | Move of int * int
  | Pass
;;




(** {1 szczegolne wartosci typow danych} *)

(** stala oznaczajaca ruch pasujacy *)
let pass = Pass;;

(** stan gry podczas, gdy jest nieaktywna *)
let unactive_state = { 
  active_player = Black;
  history = []; 
  number_of_passes = 0;
  number_of_moves = 0;
};;




(** {1 zmienne globalne } *)

(** aktualny rozmiar planszy *)
let board_size = ref 0;;

(** wartosc "komi" *)
let komi = ref 0.0;;

(** gorny limit ruchow w grze *)
let moves_limit = ref 0;;

(** czy funkcja valid_state jest juz wywolana 
    (potrzebne, aby uniknac zapetlen wywolania tej funkcji) *)
let being_validated = ref false;;




(** {1 referencje do funkcji zdefiniowanych w modulach wyzszego rzedu} *)

(** funkcja obliczajaca punkty w danej konfiguracji 
    Nadpisywana przez modul glowny [Ho]. *)
let compute_score = ref (fun _ _ -> 0.0);;

(** funkcja sprawdzajaca, czy zadana konfiguracja gry jest legalna
    Nadpisywana przez modul glowny [Ho]. *)
let legal_state = ref (fun _ -> false);;





(** {1 funkcje kontrolujace poprawnosc danych} *)

(** funkcja sprawdzajaca poprawnosc stanu gry *)
let valid_state st =
  if !being_validated then true else begin
    being_validated := true;
    if st.history = [] && st <> unactive_state then false else
    if st.number_of_passes < 0 || st.number_of_passes > 2 then false else
    if st.number_of_moves < 0 || st.number_of_moves > !moves_limit then false else
    true
  end
;;




(** {1 funkcje pomocnicze} *)

(** funkcja okresla, czy pole o zadanych wspolrzednych w ukladzie
    wspolrzednych planszy miesci sie na planszy, czy nie *)
let in_bounds (x, y) =
  let n = !board_size in
  assert (n > 0);
  if x < 1 || x > n || y < 1 || y > n then false else
  if x > n / 2 && x - y > n / 2 then false else
  if y > n / 2 && y - x > n / 2 then false else
  true
;;  
  



(** {1 konstruktory} *)

(** funkcja zamieniajaca wspolrzedne pola na ruch oznaczajacy
    postawienie na typ polu pionka *)
let construct_move (x, y) = Move (x, y);;


(** poczatkowy stan gry *)
let beginning () = 
  let n = !board_size in
  assert (n > 0); 
  { active_player = Black;
    history = [ Array.init n (fun _ -> Array.make n Empty) ];
    number_of_passes = 0; 
    number_of_moves = 0;
  }
;;
  



(** {1 iteracje} *)

(** iteracja funkcji danej jako argument po wszystkich polach planszy *)
let iter f =
  let n = !board_size in
  assert (n > 0);
  for i = 1 to n do
    for j = 1 to n do
      if in_bounds (i, j) then f (i, j);
    done;
  done;
;;




(** {1 selektory} *)

(** funkcja wyluskujaca z ruchu wspolrzedne pola *)
let coordinates_of_move mv =
  match mv with
  | Move (x, y) -> (x, y)
  | Pass -> failwith "Proba wyluskania wspolrzednych pola z ruchu pasujacego"
;;


(** funkcja zwracajaca liste sasiadow danego pola *)
let neighbors (x, y) =
  let lst = [ (1, 0); (0, 1); (1, 1); (-1, 0); (-1, -1); (0, -1) ] in
  let f aku (a, b) = 
    let x' = x + a and y' = y + b in
    if in_bounds (x', y') then (x', y') :: aku else aku in
  List.fold_left f [] lst
;;


(** funkcja wyluskujaca ze stanu gry aktywnego gracza *)
let get_player st = st.active_player;;


(** funkcja okreslajaca stan danego pola w danej konfiguracji *)
let get_field_state st (x, y) =
  assert (valid_state st);
  assert (st.history <> []);
  assert (in_bounds (x, y));
  let tab = List.hd st.history in
  tab.(x - 1).(y - 1)
;;


(** funkcja wyluskujaca ze stanu liczbe ostatnich ruchow pasujacych *)
let get_passes st = st.number_of_passes;;


(** funkcja wyluskujaca ze stanu liczbe wykonanych ruchow *)
let get_moves st = st.number_of_moves;;


(** funkcja zwracajaca liste elementow grupy danego pola *)
let group st (x, y) = 
  match get_field_state st (x, y) with
  | Empty -> []
  | Full player -> begin
    let n = !board_size in
    assert (n > 0);
    let visit = Array.init n (fun _ -> Array.make n false) in 
    let q = ref [(x, y)] in
    visit.(x - 1).(y - 1) <- true;
    let res = ref [] in
    while !q <> [] do
      let (x', y') = List.hd !q in
      assert (visit.(x' - 1).(y' - 1) = true);
      q := List.tl !q;
      match get_field_state st (x', y') with
      | Empty -> ()
      | Full pl -> if pl = player then begin
        res := (x', y') :: !res;
        let nbrs = neighbors (x', y') in
        let f aku (a, b) =
          if not (visit.(a - 1).(b - 1)) then begin
            visit.(a - 1).(b - 1) <- true;
            (a, b) :: aku 
          end else aku in
        q := List.fold_left f !q nbrs;
      end
    done;
    !res
  end
;;


(** funkcja sprawdzajaca, czy grupa ma oddechy *)
let is_alive st (x, y) = 
  assert (valid_state st);
  let stones = group st (x, y) in
  let f (x, y) = get_field_state st (x, y) = Empty in
  List.filter f (List.flatten (List.map neighbors stones)) <> []
;;


(** funkcja sprawdzajaca, czy dane pole jest okiem danego gracza *)
let is_eye st (x, y) player =
  assert (valid_state st);
  let nbrs = neighbors (x, y) in
  let f (a, b) = 
    match get_field_state st (a, b) with
    | Full pl -> player = pl
    | Empty -> false in
  List.for_all f nbrs
;;


(** funkcja zwracajaca liste wszystkich niepustych pol *)
let non_empty st =
  assert (valid_state st);
  let lst = ref [] in
  let f (x, y) = 
    if get_field_state st (x, y) = Empty then lst := (x, y) :: !lst in
  iter f;
  assert (!lst <> []);
  List.rev !lst
;;




(** {1 modyfikatory} *)

(** funkcja zwracajaca przeciwnika *)
let other = function
  | White -> Black
  | Black -> White
;;


(** funkcja wykonujaca ruch (przeksztalcajaca stany gry) *)
let make_move st mv = 
  assert (valid_state st);
  assert (st.history <> []);
  match mv with
  | Pass -> {
    active_player = other st.active_player;
    history = (List.hd st.history) :: st.history;
    number_of_passes = min 2 (st.number_of_passes + 1);
    number_of_moves = st.number_of_moves + 1;
    }
  | Move (x, y) -> begin
    assert (st.history <> []);
    let player = get_player st in
    
    (* kopiowanie ostatniego zdjecia planszy *)
    let n = !board_size in
    let tab = Array.init n (fun _ -> Array.make n Empty) in
    for i = 1 to n do
      for j = 1 to n do
        tab.(i - 1).(j - 1) <- (List.hd st.history).(i - 1).(j - 1);
      done;
    done;
    
    (* wstepnie przeksztalcony stan *)
    let new_state = { 
      active_player = other st.active_player;
      history = tab :: st.history;
      number_of_passes = 0;
      number_of_moves = st.number_of_moves + 1;
    } in
    
    (* postawienie pionka na planszy *)
    tab.(x - 1).(y - 1) <- Full st.active_player;
  
    (* zdjecie uduszonych grup przeciwnika *)
    let try_to_kill (x', y') =
      if not (is_alive new_state (x', y')) then
        let g (x'', y'') = tab.(x'' - 1).(y'' - 1) <- Empty in
        List.iter g (group new_state (x', y')) in
    let f (a, b) = get_field_state new_state (a, b) = Full (other player) in
    let lst = List.filter f (neighbors (x, y)) in
    List.iter try_to_kill lst;
  
    (* zdjecie wlasnej grupy jesli byla uduszona *)
    try_to_kill (x, y);
    
    (* zwrocenie przeksztalconego stanu *)
    new_state
  end
;;


(** funkcja cofajaca ruch przeksztalcajaca stany gry) *)
let cancel_move st = 
  assert (valid_state st);
  assert (st.history <> []);
  if List.tl st.history = [] then 
    st
  else {
    active_player = other st.active_player;
    history = List.tl st.history;
    number_of_passes = max 0 (st.number_of_passes - 1);
    number_of_moves = st.number_of_moves - 1;
  }
;;
