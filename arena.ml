(** Modul odpowiadajacy za zarzadzanie graficzna strona areny gry 
    @author Marian Marek Kedzierski *)

(** {b Uwaga}: wszystkie funkcje w tym module rysuja na pixmapie - buforze, 
    z wyjatkiem expose oraz refresh. Aby efekty staly sie widoczne
    nalezy kazdorazowo odswiezyc arene z uzyciem funkcji refresh *)

(** {1 stale} *)

(** wysokosc areny gry *)
let arena_height = 600;;

(** szerokosc areny gry *)
let arena_width = 650;;

(** grubosc marginesu *)
let margin = 30;;

(** maksymalny promien pola *)
let max_field_radius = 50.0;;


(** {0 {b kolory}} *)

let white = `WHITE;;
let black = `BLACK;;
let red = `NAME "red";;
let orange = `NAME "orange";;
let brown = `NAME "brown";;
let blue = `NAME "blue";;
let yellow = `NAME "yellow";;
let grey = `NAME "grey";;




(** {1 zmienne globalne} *)

(** bitmapa przechowujaca kopie areny *)
let backing = ref (GDraw.pixmap ~width:arena_width ~height:arena_height ());;

(** widget typu drawing_area, na ktorym rysujemy *)
let arena = ref (GMisc.drawing_area ());;

(** aktualnie podswietlone pole *)
let (highlighted_field : (int * int) option ref) = ref None;;


(** {0 {b atrybuty planszy} } *)

(** rozmiar jednego pola *)
let field_radius = ref 0.0;;

(** wektor jednostkowy [u]
    (odpowiadajacy literze w adresowaniu protokolu GTP) *)
let vector_u = ref (0.0, 0.0);;

(** wektor jednostkowy [v]
    (odpowiadajacy liczbie w adresowaniu protokolu GTP) *)
let vector_v = ref (0.0, 0.0);;

(** poczatek ukladu wspolrzednych *)
let origin = ref (0.0, 0.0);;




(** {1 funkcje pomocnicze} *)

(** podniesienie liczby zmiennoprzecinkowej do kwadratu *)
let square x = x *. x;;




(** {1 funkcje zarzadzajace rysowaniem areny } *)

(** maksymalna odleglosc myszy od pola, aby to pole bylo jej przypisane
    przy jej ruchu lub kliknieciu *)
let max_mouse_dist () = 3.0 *. !field_radius;;


(** funkcja kopiujaca zawartosc bufora na ekran *)
let refresh () = 
  let drawing =
    !arena#misc#realize ();
    new GDraw.drawable (!arena#misc#window)
  in
  drawing#put_pixmap ~x:0 ~y:0 ~xsrc:0 ~ysrc:0 
    ~width:arena_width ~height:arena_height !backing#pixmap;
;;


(** funkcja czyszczaca arene *)
let clear () =
  !backing#set_foreground yellow;
  !backing#rectangle ~x:0 ~y:0 ~width:arena_width ~height:arena_height 
    ~filled:true ();
;;


(** funkcja konwertujaca wspolrzedne pola w ukladzie wspolrzednych
    planszy do ukladu wspolrzednych ekranu - miejsca, gdzie to pole
    jest rysowane. Numeracja pol planszy zaczyna sie od 1 *)
let board_to_screen_coord (u, v) = 
  let (beg_x, beg_y) = !origin
  and (ux, uy) = !vector_u
  and (vx, vy) = !vector_v
  and u' = float_of_int u
  and v' = float_of_int v in
  let x = int_of_float (beg_x +. (u' -. 1.0) *. ux +. (v' -. 1.0) *. vx)
  and y = int_of_float (beg_y +. (u' -. 1.0) *. uy +. (v' -. 1.0) *. vy) in
  (x, y)
;;
  
  
(** funkcja konwertujaca wspolrzedne pola w ukladzie wspolrzednych
    ekranu do ukladu wspolrzednych planszy. Uzywana jako funkcja
    pomocnicza przy obsludze zdarzen myszy. Zwraca (int * int) option,
    gdyz moze sie zdarzyc, ze mysz jest zbyt daleko od jakiegokolwiek
    pola, aby do jej pozycji bylo przypisane jakies pole *)
let screen_to_board_coord (u, v) = 
  let dist = ref infinity in
  let best = ref (0, 0) in
  let f (x', y') =
    let (x, y) = board_to_screen_coord (x', y') in
    let my_dist_square = (x - u) * (x - u) + (y - v) * (y - v) in
    let my_dist = sqrt (float_of_int my_dist_square) in
    if !dist > my_dist then begin
      dist := my_dist;
      best := (x', y');
    end in
  Structs.iter f;
  if !dist > max_mouse_dist () then 
    None
  else
    Some !best
;;
  
  
(** funkcja rysujaca pojedyncze pole na buforze
    @param u odcieta pola w ukladzie wspolrzednych planszy (nie ekranu)
    @param v rzedna pola w ukladzie wspolrzednych planszy (nie ekranu)
    @param opt opcja wskazujaca docelowy stan pola (puste, zajete przez
      gracza bialego lub czarnego) lub podswietlone (dla bialego lub czarnego
      gracza. *)
let draw_field (u, v) ~opt =
  begin
    match opt with 
      | `FULL Structs.White -> !backing#set_foreground white;
      | `FULL Structs.Black -> !backing#set_foreground black;
      | `EMPTY -> !backing#set_foreground yellow;
      | `HIGHLIGHT Structs.White -> !backing#set_foreground orange;
      | `HIGHLIGHT Structs.Black -> !backing#set_foreground brown;
      | `HINT -> !backing#set_foreground blue;
  end;
  let (x', y') = board_to_screen_coord (u, v) in
  let x = x' - int_of_float !field_radius
  and y = y' - int_of_float !field_radius in
  let field_size = int_of_float (!field_radius *. 2.0) in
  
  (* wypelnienie *)
  !backing#arc ~x ~y ~width:field_size ~height:field_size ~filled:true ();
  
  (* obwodka *)
  !backing#set_foreground black;
  !backing#arc ~x ~y ~width:field_size ~height:field_size ~filled:false ();
;;


(** funkcja przygotowujaca plansze. Przygotowuje funkcje obliczajaca 
    wspolrzedne pol oraz rysuje plansze (na pixmapie [backing]) 
    @raise Invalid_board_size wyjatek podnoszony jesli podany rozmiar 
      planszy jest niedozwolony (parzysty, za maly lub za duzy) *)
let prepare_board ~size = 
  (* rozmiar planszy musi byc liczba nieparzysta, nie za mala i nie za duza *)
  if not (Rules.is_board_size_valid size) then 
    raise (Rules.Invalid_board_size size);

  Structs.board_size := size;
  
  (* wspolrzedne srodka planszy *)
  let center_x = float_of_int arena_width /. 2.0
  and center_y = float_of_int arena_height /. 2.0 in
  
  (* promien planszy *)
  let radius = (min center_x center_y) -. float_of_int margin in
  
  
  (*** ustalenie parametrow planszy *)
  
  (* polowa calej wysokosci planszy *)
  let height = radius *. (sqrt 3.0) /. 2.0 in
  
  let edge_size = float_of_int (size / 2) in
  origin := (center_x -. radius /. 2.0, center_y +. height);
  vector_u := (radius /. edge_size, 0.0);
  vector_v := (-.radius /. edge_size /. 2.0, -.height /. edge_size);
  let length_u = sqrt (square (fst !vector_u) +. square (snd !vector_u)) 
  and length_v = sqrt (square (fst !vector_v) +. square (snd !vector_v)) in
  field_radius := min max_field_radius ( min length_u length_v /. 3.0 );
  
  
  (* rysowanie planszy *)
  clear ();
  
  (* rysowanie siatki *)
  !backing#set_foreground grey;
  for i = 1 to size do
    for j = 1 to size do
      if Structs.in_bounds (i, j) then begin
        let (x, y) = board_to_screen_coord (i, j)
        and (x1, y1) = board_to_screen_coord ((i + 1), j)
        and (x2, y2) = board_to_screen_coord (i, (j + 1))
        and (x3, y3) = board_to_screen_coord ((i + 1), (j + 1)) in
        
        if Structs.in_bounds ((i + 1), j) then !backing#line x y x1 y1;
        if Structs.in_bounds (i, (j + 1)) then !backing#line x y x2 y2;
        if Structs.in_bounds ((i + 1), (j + 1)) then !backing#line x y x3 y3;
      end
    done;
  done;
  
  (* rysowanie pol *)
  for i = 1 to size do
    for j = 1 to size do
      if Structs.in_bounds (i, j) then draw_field (i, j) `EMPTY;
    done;
  done;
  
  (** skopiuj bufor [backing] na ekran *)
  refresh ();
;;




(** {1 funkcje obslugujace zdarzenia } *)

(** funkcja przechwytujaca zaznaczenie pola *)
let button_pressed (area:GMisc.drawing_area) (backing:GDraw.pixmap ref) ev =
  if !Game.game_is_running  &&  Player.human_is_moving !Game.current_state then
    if GdkEvent.Button.button ev = 1 then begin
      let x = int_of_float (GdkEvent.Button.x ev) in
      let y = int_of_float (GdkEvent.Button.y ev) in
      match screen_to_board_coord (x, y) with
      | None -> ()
      | Some (u, v) -> 
        let mv = Structs.construct_move (u, v) in
        if Rules.legal_move !Game.current_state mv then begin
          (* usuniecie podswietlenia *)
          highlighted_field := None;
          
          (* wykonanie ruchu *)
          Game.make_move (u, v);
        end
    end;
  true
;;


(** funkcja podswietlajaca pola przy ruchu myszka *)
let motion_notify (area:GMisc.drawing_area) (backing:GDraw.pixmap ref) ev =
  let (x, y) =
    if GdkEvent.Motion.is_hint ev
        then area#misc#pointer
        else
      (int_of_float (GdkEvent.Motion.x ev), int_of_float (GdkEvent.Motion.y ev))
  in
  
  (* zgaszenie aktualnie podswietlanego pola *)
  begin 
    match !highlighted_field with
    | Some (a, b) -> draw_field (a, b) `EMPTY;
    | None -> ()
  end;
  highlighted_field := None;
    
  (* zapalenie nowego *)
  if !Game.game_is_running && Player.human_is_moving !Game.current_state then begin
    match screen_to_board_coord (x, y) with 
      | Some (u, v) -> 
        if Structs.get_field_state !Game.current_state (u, v) = Structs.Empty then begin
          draw_field (u, v) (`HIGHLIGHT (Structs.get_player !Game.current_state));
          highlighted_field := Some (u, v);
        end
      | None -> ()
  end;
    
  (* odswiezenie ekranu *)
  refresh ();
  true
;;  


(** Przerysowuje arene z pixmapy [backing] *)
let expose (drawing_area:GMisc.drawing_area) (backing:GDraw.pixmap ref) ev =
  let area = GdkEvent.Expose.area ev in
  let x = Gdk.Rectangle.x area in
  let y = Gdk.Rectangle.y area in
  let width = Gdk.Rectangle.width area in
  let height = Gdk.Rectangle.width area in
  let drawing =
    drawing_area#misc#realize ();
    new GDraw.drawable (drawing_area#misc#window)
  in
  drawing#put_pixmap ~x ~y ~xsrc:x ~ysrc:y ~width ~height !backing#pixmap;
  false
;;


(** Tworzy pixmape [backing] *)
let configure window backing ev =
  let width = GdkEvent.Configure.width ev in
  let height = GdkEvent.Configure.height ev in
  let pixmap = GDraw.pixmap ~width ~height ~window () in
  
  backing := pixmap;
  clear();
  true
;;




(** {1 pozostale funkcje} *)

(** stworzenie areny graficznej gry *)
let build_arena ~packing ~window = 
  arena := GMisc.drawing_area 
    ~width:arena_width ~height:arena_height ~packing ();
    
  (* sygnaly dotyczace bufora backing *)
  !arena#event#connect#configure ~callback:(configure window backing);  
  !arena#event#connect#expose ~callback:(expose !arena backing);
  
  (* sygnaly zdarzen *)
  !arena#event#connect#motion_notify ~callback:(motion_notify !arena backing);
  !arena#event#connect#button_press ~callback:(button_pressed !arena backing);
  
  !arena#event#add [`EXPOSURE; `LEAVE_NOTIFY; `BUTTON_PRESS; `POINTER_MOTION; `POINTER_MOTION_HINT];
;;
