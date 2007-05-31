(** Modul odpowiedzialny za boczny pasek z przyciskami
    @author Marian Marek Kedzierski *)

(** {1 zmienne globalne} *)

(** pole informacji o numerze ruchu *)
let nth_move_info = ref (GMisc.label ());;

(** pole informacji o gornym limicie ruchow *)
let moves_limit_info = ref (GMisc.label ());;

(** pole informacji o wyniku czarnego *)
let black_score_info = ref (GMisc.label ());;

(** pole informacji o wyniku bialego *)
let white_score_info = ref (GMisc.label ());;




(** {1 stale} *)

(** szerokosc pola z przyciskami *)
let button_box_width = 150;;

(** szerokosc marginesu pola z przyciskami *)
let button_box_border = 10;;




(** {1 funkcje wypisujace informacje tekstowe} *)

(** informacja o aktualnym numerze ruchu *)
let nth_move_text () =
  if !Game.current_state = Structs.unactive_state then
    "Brak ruchów"
  else
    let moves = Structs.get_moves !Game.current_state in
    Printf.sprintf "Ruch nr: %d" moves;
;;


(** informacja o aktualnym gornym limicie ruchow *)
let moves_limit_text () =
  if !Game.current_state = Structs.unactive_state then
    "Limit ruchów: brak"
  else
    let moves_limit = !Structs.moves_limit in
    Printf.sprintf "Limit ruchów: %d" moves_limit;
;;


(** informacja o aktualnym wyniku czarnego *)
let black_score_text () =
  if !Game.current_state = Structs.unactive_state then
    "CZARNY: brak pkt"
  else
    let score = Rules.compute_score !Game.current_state Structs.Black in 
    Printf.sprintf "CZARNY: %.1f pkt" score;
;;


(** informacja o aktualnym wyniku bialego *)
let white_score_text () =
  if !Game.current_state = Structs.unactive_state then
    "BIAŁY: brak pkt"
  else
    let score = Rules.compute_score !Game.current_state Structs.White in 
    Printf.sprintf "BIAŁY: %.1f pkt" score;
;;




(** {1 funkcje uaktualniajace wyswietlane informacje } *)

(** Funkcja uaktualniajaca wyswietlane dane tekstowe (w pasku przyciskow) *)
let update_text_info st = 
  if !Game.game_is_active || not !Game.showing_score then begin
    !nth_move_info#set_text (nth_move_text ());
    !moves_limit_info#set_text (moves_limit_text ());
    !black_score_info#set_text (black_score_text ());
    !white_score_info#set_text (white_score_text ());
  end;
;;
    
    


(** {1 funkcje odpowiadajace przyciskom, niezdefiniowane gdzie indziej} *)

(** funkcja dajaca podpowiedz graczowi w razie potrzeby *)
let give_hint () = 
  if !Game.game_is_running then begin
    let move = Player.wise_move !Game.current_state in
    assert (Rules.legal_move !Game.current_state move);
    
    if move = Structs.pass then begin
      Interface_elems.view_information ~title:"Podpowiedź" ~text:"Pasuj" ();
    end else begin
      let (x, y) = Structs.coordinates_of_move move in
      (* chwilowe podswietlenie pola *)
      Arena.draw_field (x, y) `HINT;
      Arena.refresh ();
      
      Arena.draw_field (x, y) `EMPTY;
      Arena.refresh ();
    end;
  end else
    Interface_elems.view_information ~title:"Podpowiedź" 
      ~text:"Gra jest nieaktywna" ();
;;




(** {1 funkcja glowna modulu} *)

(** funkcja tworzaca boczny pasek z przyciskami *)
let create_side_bar ~packing =
  let button_box = GPack.vbox ~packing
    ~width:button_box_width ~border_width:button_box_border () in
  
  (** kolejne przyciski w polu przyciskow **)
  
  let make_button = Interface_elems.make_button in
  make_button ~name:"Cofnij ruch" ~button_box ~callback:Game.cancel_move;
  make_button ~name:"Pasuj" ~button_box ~callback:Game.do_pass;
  make_button ~name:"Podpowiedź" ~button_box ~callback:give_hint;
  make_button ~name:"Wstrzymaj grę" ~button_box ~callback:Game.pause;
  make_button ~name:"Wznów grę" ~button_box ~callback:Game.resume;
  
  
  let separator = GMisc.separator `HORIZONTAL () in
  button_box#pack ~expand:true ~fill:false separator#coerce;
  
  
  (** pola informacji tekstowych **)
  
  (* pole informacji o numerze ruchu *)
  nth_move_info := GMisc.label ~text:(nth_move_text ()) ();
  button_box#pack !nth_move_info#coerce;
  
  (* pole informacji o gornym limicie ruchow *)
  moves_limit_info := GMisc.label ~text:(moves_limit_text ()) ();
  button_box#pack !moves_limit_info#coerce;
  
  (* pole informacji o aktualnym wyniku czarnego *)
  black_score_info := GMisc.label ~text:(black_score_text ()) ();
  button_box#pack !black_score_info#coerce;
  
  (* pole informacji o aktualnym wyniku bialego *)
  white_score_info:= GMisc.label ~text:(white_score_text ()) ();
  button_box#pack !white_score_info#coerce;
  
  
  let separator = GMisc.separator `HORIZONTAL () in
  button_box#pack ~expand:true ~fill:false separator#coerce;
  
  
  (** przycisk konczacy gre **)
  make_button ~name:"Zakończ" ~button_box ~callback:Game.quit;
;;
