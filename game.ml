(** Modul odpowiedzialny za zarzadzanie przebiegiem gry
    @author Marian Marek Kedzierski *)

(** {1 zmienne globalne } *)

(** czy gra trwa obecnie (lub ewentualnie jest wstrzymana)? *)
let game_is_active = ref false;;

(** czy gra trwa i nie jest wstrzymana? *)
let game_is_running = ref false;;

(** czy w tej chwili wyswietlany jest wynik skonczonej gry? *)
let showing_score = ref false;;

(** jaki jest aktualny stan gry *)
let current_state = ref Structs.unactive_state;;

(** identyfikator funkcji wywolywanej okresowo dla komputera *)
let computer_id = ref (GMain.Timeout.add ~ms:1 ~callback:(fun () -> false));;

(** identyfikator funkcji wywolywanej okresowo dla sprawdzenia,
    czy gra juz sie skonczyla *)
let finish_check_id = ref (GMain.Timeout.add ~ms:1 ~callback:(fun () -> false));;




(** {1 stale} *)

(** czas w milisekundach pomiedzy kolejnymi wywolaniami funkcji
    kontrolujacej stan gry *)
let control_time = 100;;




(** {1 referencje do funkcji (uzywane do wplywania na wewnetrzna strukture 
    wyzszych modulow} *)

(** referencja do funkcji uaktualniajacej wyswietlane na ekranie dane
    o aktualnym stanie gry (z wyjatkiem areny gry). Poczatkowo jest to
    funkcja pusta, dopiero modul [Interface] w odpowiednim momencie
    czyni ja funkcja dzialajaca na jego wewnetrznej strukturze. *)
let update_displayed_info = ref (fun _ -> ());;


(** referencja do funkcji uaktualniajacej tylko pasek stanu *)
let update_text_info = ref (fun _ -> ());;


(** referencja do funkcji przygotowujacej arene do rozgrywki.
    Nadpisywana przez modul [Arena] *)
let prepare_arena = ref (fun ~size -> ());;


(** referencja do funkcji czyszczacej arene po rozgrywce.
    Nadpisywana przez modul [Arena] *)
let clear_arena = ref (fun () -> ());;


(** referencja do funkcji wykonujacej ruch w imieniu gracza czarnego.
    Nadpisywana przez funkcje [Interface.new_game] *)
let black_make_move = ref (fun _ -> Structs.construct_move (0, 0));;


(** referencja do funkcji wykonujacej ruch w imieniu gracza bialego
    Nadpisywana przez funkcje [Interface.new_game] *)
let white_make_move = ref (fun _ -> Structs.construct_move (0, 0));;

(** referencja do funkcji wyswietlajacej okno dialogowe z informacja.
    Nadpisywana przez modul glowny programu [Ho].
    @param title Tytul okienka dialogowego
    @param text Tekst do wyświetlenia *)
let view_information = ref (fun ~title ~text () -> ());;




(** {1 funkcje zarzadzajace gra} *)

(** funkcja wykonujaca ruch niepasujacy (w imieniu czlowieka) *)
let make_move (x, y) =
  let player = Structs.get_player !current_state in
  if !game_is_running && Player.is_human player then begin
    let mv = Structs.construct_move (x, y) in
    assert (Rules.legal_move !current_state mv);
    current_state := Structs.make_move !current_state mv;
    !update_displayed_info !current_state;
  end
;;


(** funkcja pasujaca w imieniu aktywnego gracza *)
let do_pass () =
  let player = Structs.get_player !current_state in
  if !game_is_running then begin
    if Player.is_human player then begin
      current_state := Structs.make_move !current_state Structs.pass;
      !update_displayed_info !current_state;
    end;
  end else
    !view_information ~title:"Pasowanie" ~text:"Gra jest nieaktywna!" ();
;;


(** funkcja wykonujaca ruch w imieniu komputera (wywolywana okresowo
    przez petle glowna programu). Zwraca true (na znak, ze chce byc
    nadal wywolywana) *)
let computer_make_move () =
  let player = Structs.get_player !current_state in
  if !game_is_running && Player.is_computer player then begin
      let mv = match player with
      | Structs.White -> !white_make_move !current_state 
      | Structs.Black -> !black_make_move !current_state in
      assert (Rules.legal_move !current_state mv);
      
      current_state := Structs.make_move !current_state mv;
      !update_displayed_info !current_state;
    end;
  true
;;


(** funkcja cofajaca ruchy *)
let cancel_move () =
  if !game_is_active then begin
    current_state := Structs.cancel_move !current_state;
    !update_displayed_info !current_state;
  end else
    !view_information ~title:"Cofanie ruchu" ~text:"Gra jest nieaktywna!" (); 
;;


(** funkcja zawieszajaca gre *)
let pause () =
  if !game_is_active then 
    game_is_running := false
  else
    !view_information ~title:"Wstrzymywanie gry" ~text:"Gra jest nieaktywna!" ();
;;


(** funkcja wznawiajaca gre *)
let resume () =
  if !game_is_active then 
    game_is_running := true
  else
    !view_information ~title:"Wznawianie gry" ~text:"Gra jest nieaktywna!" ();
;;


(** funkcja "sprzatajaca" po grze *)
let tidy () =
  if !game_is_active then begin
    game_is_active := false;
    game_is_running := false;
    showing_score := true;
    
    Structs.board_size := 0;
    Structs.komi := 0.0;
    Structs.moves_limit := 0;
    current_state := Structs.unactive_state;
    
    GMain.Timeout.remove !computer_id;
    GMain.Timeout.remove !finish_check_id;
    
    Player.white_user := Player.No_user;
    Player.black_user := Player.No_user;
    
    !update_text_info !current_state;
  end
;;


(** funkcja konczaca aktualna gre i informujaca o wyniku, ale nie wymazujaca
    wyswietlanych informacji *)
let end_game () =
  if !game_is_active then begin
    (* informacja o wyniku gry *)
    let wh_score = Rules.compute_score !current_state Structs.White in
    let bl_score = Rules.compute_score !current_state Structs.Black in
    if wh_score > bl_score then begin
      !view_information ~title:"Koniec gry" ~text:"Gracz biały wygrał!" ();
    end else begin
      !view_information ~title:"Koniec gry" ~text:"Gracz czarny wygrał!" ();
    end;
    
    (* sprzatanie *)
    tidy ();
  end
;;


(** funkcja sprawdzajaca, czy gra przypadkiem juz sie nie skonczyla *)
let check_if_finished () =
  if Rules.finished !current_state then begin 
    end_game ();
    false;
  end else 
    true
;;


(** funkcja rozpoczynajaca gre (i ja przeprowadzajaca) *)
let start ~board_size ~komi ~moves_limit =
  !prepare_arena board_size;
  
  Structs.komi := komi;
  Structs.moves_limit := moves_limit;
  current_state := Structs.beginning ();
  
  computer_id := GMain.Timeout.add ~ms:Player.hesitate_time 
    ~callback:computer_make_move;
  finish_check_id := GMain.Timeout.add ~ms:control_time 
    ~callback:check_if_finished;
  
  game_is_active := true;
  game_is_running := true;
  showing_score := false;
  
  !update_displayed_info !current_state;
;;  


(** funkcja wychodzaca z aktualnej gry (sprzatajaca po niej) *)
let quit () =
  if !game_is_active then 
    tidy ()
  else begin
    showing_score := false;
    !update_displayed_info !current_state;
  end;
;;
