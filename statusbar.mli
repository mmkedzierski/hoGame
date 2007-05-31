(** Modul odpowiedzialny za pasek stanu 
    @author Marian Marek Kedzierski *)
    
(** funkcja uaktualniajaca wyswietlane na pasku stanu informacje *)
val update_statusbar : Structs.state -> unit;;

(** funkcja tworzaca pasek stanu *)
val create_statusbar : packing:(GObj.widget -> unit) -> unit;;
