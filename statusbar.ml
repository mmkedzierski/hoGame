(** Modul odpowiedzialny za pasek stanu 
    @author Marian Marek Kedzierski *)
    
(** {1 zmienne globalne} *)

(** kontekst paska stanu *)
let statusbar_context = ref ( (GMisc.statusbar ())#new_context ~name:"");;




(** {1 funkcje pomocnicze} *)

(** informacja do paska stanu o aktywnym graczu *)
let player_info = function
  | Structs.White -> "Ruch wykonuje gracz biały"
  | Structs.Black -> "Ruch wykonuje gracz czarny"
;;




(** {1 funkcje z sygnatury} *)

(** funkcja uaktualniajaca wyswietlane na pasku stanu informacje *)
let update_statusbar st =
  (!statusbar_context)#pop ();
  if !Game.game_is_active then
    ignore ((!statusbar_context)#push (player_info (Structs.get_player st)));
;;


(** funkcja tworzaca pasek stanu *)
let create_statusbar ~packing =
  let statusbar = GMisc.statusbar ~packing () in
  statusbar_context := statusbar#new_context ~name:"Pasek stanu";
;;
