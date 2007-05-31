(** Modul odpowiedzialny za funkcje pomocnicze tworzace powtarzajace sie 
    elementy interfejsu
    @author Marian Marek Kedzierski *)

(** funkcja tworzaca przycisk do paska z przyciskami *)
let make_button ~name ~(button_box:GPack.box) ~callback =
  let button = GButton.button ~label:name () in
  button_box#pack ~expand:true ~fill:false button#coerce;
  button#connect#clicked ~callback;
  ()
;; 


(** funkcja tworzaca skladnik "radio button" - zestawu opcji,
    z ktorych mozna wybrac jedna. Zwraca grupe danego skladnika. *)
let make_radio_button ?group ~name ~packing ~callback =
  let button = GButton.radio_button ~label:name 
    ?group ~packing () in
  button#connect#clicked ~callback;
  button#group
;;
  

(** funkcja tworzaca trojke (etykieta, spin_button, adjustment) 
    o odpowiednich parametrach, gotowe do umieszczenia w tabeli 
    w oknie "Nowa gra" *)
let make_spin_button ~name ~min ~max ~step ~value ~digits () =
  let label = GMisc.label ~text:name () in
  
  let adjustment = GData.adjustment ~value ~step_incr:step
    ~lower:min ~upper:max () in
  let spinb = GEdit.spin_button ~adjustment ~digits ~numeric:true 
    ~width:100 ~height:25 () in
  
  (label, spinb, adjustment)
;;


(** funkcja pokazujaca zadane informacje w oknie dialogowym o programie 
    @param title Tytul okienka dialogowego
    @param text Tekst do wyswietlenia *)
let view_information ~title ~text () = 
  let dialog = GWindow.dialog ~title ~width:300 ~height:200 
    ~show:true ~destroy_with_parent:true ~resizable:false () in
  let _ = GMisc.label ~text ~justify:`CENTER ~line_wrap:true 
    ~packing:dialog#vbox#add () in
  
  (* przycisk OK ... *)
  let ok_button = GButton.button ~label:"OK" ~packing:dialog#action_area#add () in
  ok_button#connect#clicked ~callback:(dialog#destroy);
  ok_button#grab_default ();
;;  
