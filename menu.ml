(** Modul odpowiedzialny za skladniki menu w interfejsie.
    @author Marian Marek Kedzierski *)


(** {1 funkcje pomocnicze} *)

(** funkcja tworzaca nowe menu *)
let create_menu label menubar =
  let item = GMenu.menu_item ~label ~packing:menubar#append () in
  GMenu.menu ~packing:item#set_submenu ()
;;




(** {1 funkcje odpowiedzialne za skladniki menu} *)

(** funkcja tworzaca okno dialogowe "Nowa gra" *)
let new_game () = 
  let dialog = GWindow.dialog ~title:"Nowa gra" ~width:400 ~height:300 
    ~show:true ~destroy_with_parent:true ~resizable:false () in
  let _ = GMisc.label ~text:"Wybierz opcje gry" ~packing:dialog#vbox#add () in
  let _ = GMisc.separator `HORIZONTAL ~packing:dialog#vbox#add () in
  
  (* schemat okna dialogowego *)
  let players_box = GPack.hbox ~packing:dialog#vbox#add () in
  let black_part = GPack.vbox ~packing:players_box#add () in
  let _ = GMisc.separator `VERTICAL ~packing:players_box#add () in
  let white_part = GPack.vbox ~packing:players_box#add () in
  
  let _ = GMisc.label ~text:"GRACZ CZARNY" ~packing:black_part#add () in
  let _ = GMisc.label ~text:"GRACZ BIAŁY" ~packing:white_part#add () in
  
  
  (*** ustawienia czy poszczegolni gracze maja byc ludzmi czy komputerami *)
  let black_player = ref `HUMAN in
  let white_player = ref `HUMAN in
  
  (* gracz czarny *)
  let packing = black_part#add in
  
  let black_group = Interface_elems.make_radio_button ~name:"człowiek" ?group:None 
    ~packing ~callback:(fun () -> black_player := `HUMAN) in
    
  Interface_elems.make_radio_button ~name:"komputer (IQ 0)" ~group:black_group
    ~packing ~callback:(fun () -> black_player := `RANDOM_COMPUTER);
  
  Interface_elems.make_radio_button ~name:"komputer (IQ +1)" ~group:black_group 
    ~packing ~callback:(fun () -> black_player := `COMPUTER);
  
  (* gracz bialy *)
  let packing = white_part#add in
  
  let white_group = Interface_elems.make_radio_button ~name:"człowiek" ?group:None 
    ~packing ~callback:(fun () -> white_player := `HUMAN) in
    
  Interface_elems.make_radio_button ~name:"komputer (IQ 0)" ~group:white_group 
    ~packing ~callback:(fun () -> white_player := `RANDOM_COMPUTER);
  
  Interface_elems.make_radio_button ~name:"komputer (IQ +1)" ~group:white_group
    ~packing ~callback:(fun () -> white_player := `COMPUTER);
  
   
  (*** ustawienia parametrow liczbowych *)
  let _ = GMisc.separator `HORIZONTAL ~packing:dialog#vbox#add () in
  
  let table = GPack.table ~rows:3 ~columns:2 ~homogeneous:true 
    ~packing:dialog#vbox#add () in
  
  (* wybor wielkosci planszy *)
  let min = float_of_int Rules.min_board_size in
  let max = float_of_int Rules.max_board_size in
  let step = float_of_int Rules.board_size_step in
  let value = float_of_int Rules.default_board_size in
  let (label, board_size_spinb, board_size_adj) = 
    Interface_elems.make_spin_button 
    ~name:"Wybierz rozmiar planszy:" ~min ~max ~step ~value ~digits:0 () in
  table#attach ~left:0 ~top:0 (label#coerce);
  table#attach ~left:1 ~top:0 (board_size_spinb#coerce);
    
  (* wybor komi *)
  let min = Rules.min_komi in
  let max = Rules.max_komi in
  let step = Rules.komi_step in
  let value = Rules.default_komi in
  let (label, komi_spinb, _) = 
    Interface_elems.make_spin_button 
    ~name:"Wybierz KOMI:" ~min ~max ~step ~value ~digits:1 () in
  table#attach ~left:0 ~top:1 (label#coerce);
  table#attach ~left:1 ~top:1 (komi_spinb#coerce);
    
  (* wybor limitu ruchow *)
  let min = float_of_int Rules.min_moves_limit in
  let max = float_of_int Rules.max_moves_limit in
  let step = float_of_int Rules.moves_limit_step in
  let value = float_of_int (Rules.standard_moves_limit Rules.default_board_size) in
  let (label, moves_limit_spinb, _) =  
    Interface_elems.make_spin_button 
    ~name:"Wybierz górny limit ruchów:" ~min ~max ~step ~value ~digits:0 () in
  table#attach ~left:0 ~top:2 (label#coerce);
  table#attach ~left:1 ~top:2 (moves_limit_spinb#coerce);
  
  (* funkcja zwiazujaca wybor wielkosci planszy z gornym limitem ruchow *)
  let relate () = 
    let n = board_size_spinb#value_as_int in
    assert (Rules.is_board_size_valid n);
    let moves_limit = float_of_int (Rules.standard_moves_limit n) in
    moves_limit_spinb#set_value moves_limit in
  board_size_adj#connect#value_changed ~callback:relate;
  
  
  (*** przycisk OK ... *)
  let ok_button = GButton.button ~label:"OK" 
    ~packing:dialog#action_area#add () in
  
  (* ... i jego dzialanie *)
  let accept () = 
    let board_size = board_size_spinb#value_as_int in 
    let komi = komi_spinb#value in
    let moves_limit = moves_limit_spinb#value_as_int in
    
    Game.black_make_move := begin
      match !black_player with
      | `HUMAN -> Player.no_move
      | `RANDOM_COMPUTER -> Player.random_move
      | `COMPUTER -> Player.wise_move
    end;
    Game.white_make_move := begin
      match !white_player with 
      | `HUMAN -> Player.no_move
      | `RANDOM_COMPUTER -> Player.random_move
      | `COMPUTER -> Player.wise_move
    end;
    
    Player.black_user := begin
      match !black_player with  
      | `HUMAN -> Player.Human
      | _ -> Player.Computer
    end;
    Player.white_user := begin
      match !white_player with  
      | `HUMAN -> Player.Human
      | _ -> Player.Computer
    end;
    
    try 
      dialog#destroy ();
      Game.start ~board_size ~komi ~moves_limit;
    with
    | Rules.Invalid_board_size _ -> 
      Interface_elems.view_information ~title:"Błąd" 
        ~text:"Nieprawidłowa wielkość planszy!" (); in
    
  ok_button#connect#clicked ~callback:accept;
  ok_button#grab_default ();
;;


(** funkcja pokazujaca zasady gry *)
let show_rules () = 
  let text = 
    "Zasady gry są dostępne na stronie\n" ^
    "http://games.mimuw.edu.pl\n" ^
    "\n" ^
    "Znajdują się również w katalogu bieżącym\n" ^
    "w nieco uboższej graficznie wersji." in
  Interface_elems.view_information ~title:"Zasady gry Ho" ~text ();
;;


(** funkcja pokazujaca instrukcje do gry *)
let instruction () = 
  let text = 
    "Instukcja gracza znajduje się\n" ^
    "w katalogu bieżącym." in
  Interface_elems.view_information ~title:"Instrukcja gracza" ~text ();
;;


(** funkcja pokazujaca informacje o programie *)
let about_program () = 
  let text = 
      "Jest to program napisany\n" ^
      "jako zaliczenie przedmiotu\n" ^
      "'Metody programowania - laboratorium'\n" ^
      "Autor: Marian Marek Kędzierski\n" in
  Interface_elems.view_information ~title:"O programie" ~text ();
;;




(** {1 skladniki menu} *)

(** lista elementow menu "Gra" *)
let game_entries = [
  `I ("Nowa gra", new_game);
  `S;
  `I ("Wyjdź", GMain.Main.quit)
];;

(** lista elementow menu "Pomoc" *)
let help_entries = [
  `I ("Instrukcja gracza", instruction);
  `I ("Zasady gry", show_rules);
  `S;
  `I ("O programie", about_program);
];;




(** {1 funkcja glowna modulu: tworzaca menu gry (czesc interfejsu)} *)
let create_menu ~packing =
  let menu_bar = GMenu.menu_bar ~packing () in
  let menu = create_menu "Gra" menu_bar in
  GToolbox.build_menu menu ~entries:game_entries;
  
  let menu = create_menu "Pomoc" menu_bar in
  GToolbox.build_menu menu ~entries:help_entries;
;;
