(** Modul odpowiedzialny za stworzenie ramowego interfejsu programu
    (polaczenie wszystkich jego elementow skladowych).
    @author Marian Marek Kedzierski *)

(** Funkcja uaktualniajaca wszystkie wyswietlane dane tekstowe *)
let update_text_info st = 
  (* pasek stanu *)
  Statusbar.update_statusbar st;
    
  (* informacje tekstowe na pasku z przyciskami *)
  Side_bar.update_text_info st;
;;


(** Funkcja uaktualniajaca wszystkie wyswietlane informacje
    (lacznie z arena gry) *)
let update_displayed_info st = 
  (* pasek stanu *)
  update_text_info st;
    
  (* plansza *)
  if !Game.game_is_active then begin
    let f (x, y) =
      match Structs.get_field_state st (x, y) with
      | Structs.Empty -> Arena.draw_field (x, y) `EMPTY
      | Structs.Full player -> Arena.draw_field (x, y) (`FULL player ) in
    Structs.iter f;
  end else Arena.clear ();
  
  Arena.refresh ();
;;




(** {1 glowna funkcja modulu} *)

(** stworzenie ramowego interfejsu programu *)
let build_interface () =
  let window = GWindow.window ~resizable:false ~title:"Ho" () in
  window#connect#destroy ~callback:GMain.Main.quit;

  (*** glowna skrzynka zawierajaca menu, pasek stanu i reszte ***)
  let main_vbox = GPack.vbox ~packing:window#add() in
  
  (* menu *)
  Menu.create_menu ~packing:main_vbox#add;
  
  
  (** skrzynka zawierajaca arene gry oraz skrzynke z przyciskami **)
  let main_hbox = GPack.hbox ~packing:main_vbox#add() in
  
  (* boczny pasek z przyciskami *)
  Side_bar.create_side_bar ~packing:main_hbox#add;
  
  (* arena gry *)
  Arena.build_arena ~packing:main_hbox#add ~window:window;

  
  (** pasek stanu **)
  Statusbar.create_statusbar ~packing:main_vbox#add;
  
  (*** pokazanie okna ***)
  window#show();
;;
