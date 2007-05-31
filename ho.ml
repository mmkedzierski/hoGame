(** Glowny modul gry
    @author Marian Marek Kedzierski *)

(** funkcja kontrolujaca poprawnosc *)

(** funkcja kontrolujaca poprawnosc stanu gry - wywolywana cyklicznie 
    przez petle glowna programu *)
let control_state () =
  assert (if !Game.game_is_running then !Game.game_is_active else true);
  assert (if !Game.showing_score then not !Game.game_is_active else true);
  assert (Structs.valid_state !Game.current_state);
  true (* nadal mnie wywoluj cyklicznie *)
;;
    
    
    

(** funkcja glowna programu *)
let main () =
  (* stworzenie interfejsu (polaczenie wszystkich skladnikow gry) *)
  Interface.build_interface();
  
  (* przypisania w modulach nizszego rzedu referencji do funkcji 
    z modulow wyzszego rzedu *)
  Game.update_displayed_info := Interface.update_displayed_info;
  Game.update_text_info := Interface.update_text_info;
  Game.prepare_arena := Arena.prepare_board;
  Game.clear_arena := Arena.clear;
  Game.view_information := Interface_elems.view_information;
  Structs.compute_score := Rules.compute_score;
  Structs.legal_state := Rules.legal_state;
  
  (* wywolanie funkcji kontrolujacej na biezaca poprawnosc stanu gry *)
  GMain.Timeout.add ~ms:Game.control_time ~callback:control_state;

  (* petla glowna programu *)
  GMain.Main.main();   
;;

let _ = Printexc.print main ();;
