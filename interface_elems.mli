(** Modul odpowiedzialny za funkcje pomocnicze tworzace powtarzajace sie 
    elementy interfejsu
    @author Marian Marek Kedzierski *)

(** funkcja tworzaca przycisk do paska z przyciskami *)
val make_button : name:string -> button_box:GPack.box -> 
  callback:(unit -> unit) -> unit;;

(** funkcja tworzaca skladnik "radio button" - zestawu opcji,
    z ktorych mozna wybrac jedna. Zwraca grupe danego skladnika. *)
val make_radio_button : ?group:Gtk.radio_button Gtk.group -> name:string ->
  packing:(GObj.widget -> unit) -> callback:(unit -> unit) -> 
  Gtk.radio_button Gtk.group;;
  
(** funkcja tworzaca trojke (etykieta, spin_button, adjustment) 
    o odpowiednich parametrach, gotowe do umieszczenia w tabeli 
    w oknie "Nowa gra" *)
val make_spin_button : name:string -> min:float -> max:float -> step:float ->
  value:float -> digits:int -> unit -> 
  GMisc.label * GEdit.spin_button * GData.adjustment;;

(** funkcja pokazujaca zadane informacje w oknie dialogowym o programie 
    @param title Tytul okienka dialogowego
    @param text Tekst do wyswietlenia *)
val view_information : title:string -> text:string -> unit -> unit;;
