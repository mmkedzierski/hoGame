(** Modul odpowiadajacy za zarzadzanie graficzna strona areny gry 
    @author Marian Marek Kedzierski *)

(** {b Uwaga}: wszystkie funkcje w tym module rysuja na pixmapie - buforze, 
    z wyjatkiem expose oraz refresh. Aby efekty staly sie widoczne
    nalezy kazdorazowo odswiezyc arene z uzyciem funkcji refresh *)

(** {1 stale} *)

(** wysokosc areny gry *)
val arena_height : int;;

(** szerokosc areny gry *)
val arena_width : int;;



(** {1 funkcje} *)

(** funkcja kopiujaca zawartosc bufora na ekran *)
val refresh : unit -> unit;;

(** funkcja czyszczaca arene *)
val clear : unit -> unit;;

(** funkcja przygotowujaca plansze. Przygotowuje funkcje obliczajaca wspolrzedne pol
    oraz rysuje plansze (na pixmapie [backing]) 
    @param size rozmiar budowanej planszy *)
val prepare_board : size:int -> unit;;

(** funkcja rysujaca pojedyncze pole na buforze
    @param u odcieta pola w ukladzie wspolrzednych planszy (nie ekranu)
    @param v rzedna pola w ukladzie wspolrzednych planszy (nie ekranu)
    @param opt opcja wskazujaca docelowy stan pola (puste, zajete przez
      gracza bialego lub czarnego) lub podswietlone (dla bialego lub czarnego
      gracza. *)
val draw_field : int * int -> 
  opt:[< `FULL of Structs.player_t | `EMPTY 
        | `HIGHLIGHT of Structs.player_t | `HINT] -> unit;;

(** stworzenie ramowego interfejsu programu *)
val build_arena : 
  packing:(GObj.widget -> unit) -> 
  window:< misc : #GDraw.misc_ops; .. > -> unit;;
