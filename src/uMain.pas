unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, ExtCtrls, Menus, ComCtrls, StdCtrls, MMSystem, jpeg;

type
  TfrmGame = class(TForm)
    imgBackground: TImageList;
    mnuMain: TMainMenu;
    mnuGame: TMenuItem;
    mnuLevel: TMenuItem;
    mnuHelp: TMenuItem;
    mnuAbout: TMenuItem;
    mnuSredni: TMenuItem;
    mnuNormaly: TMenuItem;
    mnuWysoki: TMenuItem;
    mnuNowaGra: TMenuItem;
    mnuZakoncz: TMenuItem;
    mnu1: TMenuItem;
    mnuWyjcie: TMenuItem;
    timTimer: TTimer;
    mnuNiski: TMenuItem;
    mnuLanguage: TMenuItem;
    pbxBackground: TPaintBox;
    FPicture: TImage;
    imgImages: TImageList;
    imgClock: TImage;
    imgUncovers: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Image1: TImage;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure mnuSredniClick(Sender: TObject);
    procedure mnuWyjcieClick(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure timTimerTimer(Sender: TObject);
    procedure mnuNowaGraClick(Sender: TObject);
    procedure mnuZakonczClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormConstrainedResize(Sender: TObject; var MinWidth, MinHeight, MaxWidth, MaxHeight: Integer);
    procedure pbxBackgroundPaint(Sender: TObject);
    procedure pbxPanelPaint(Sender: TObject);

  private
    Obrazy: Array of TImage;               // dynamiczna tablica zawierajaca obrazy
    WybraneObrazy: Array[0..1] of TImage;  // tablica zawiera pare wybranych obrazow
    LicznikCzasu, CzasStart: Int64;        // zmienne do zapamietywania czasu

    PoziomGry: Byte;              // poziom gry zawiera liczbe obrazkow w wierszu
    KtoryWybrany: Byte;           // liczba wybranych obrazkow
    IloscZnalezionych: Byte;      // liczba znalezionych par obrazkow
    IloscOdkryc: Integer;         // liczba odkryc par od poczatku gry

    MozeUstawic: Boolean;

    procedure InicjacjaObrazow;   // przygotowuje plansze do gry
    procedure UsunObrazy;         // usuwa z planszy (i z pamieci) obrazki
    procedure WyswietlCzas;       // wyswietla czas i odkrycia na ekranie

    procedure WybranyObraz(Sender: TObject);  // procedura obslugi klikniecia myszka w obrazek
    procedure PlayWAV(Name: String);
    procedure DrawTiled;
    procedure DrawStretched;
    procedure DrawCentered;

  public
  end;

var
  frmGame: TfrmGame;

const
  ODSTEP = 5;  // odstep pomiedzy obrazkami

implementation

uses uAbout;

{$R *.DFM}

procedure TfrmGame.InicjacjaObrazow;
var
  x, y, i, j, r, n: Integer;
  IlePar: Integer;

// funkcja sprawdza czy dany obrazek jest juz wybrany ( nie powinno byc 2 par z takimi samymi rysunkami )
function SprawdzObrazek(Numer: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  i := 0;
  while (i < Length(Obrazy)) and (not Result) do begin
    Result := Obrazy[i].Tag = Numer;
    inc(i);
  end;
end;

begin


  // ustalenie rozmiaru formularza
  // jezeli jest za maly to zostanie odpowiednio powiekszony
  if Width < (imgImages.Width + ODSTEP) * (PoziomGry + 3) then
    Width := PoziomGry * (imgImages.Width + ODSTEP);

  if ClientHeight < (imgImages.Height + ODSTEP) * (PoziomGry + 3) then
    ClientHeight := PoziomGry * (imgImages.Height + ODSTEP);

  // ustawienie dlugosci dynamicznej tablicy
  SetLength(Obrazy, PoziomGry * PoziomGry);
  i := 0;


  // utworzenie wszystkich rysunkow (TImage) wedlug poziomu gry
  for y := 0 to PoziomGry - 1 do
    for x := 0 to PoziomGry - 1 do begin
      Obrazy[i] := TImage.Create(nil);    // utworzenie komponentu TImage
      with Obrazy[i] do begin
        Parent := Self;                   // ustawienie wlasciciela rysunku na forme
        Width := imgImages.Width;         // ustawienie szerokosci obrazka
        Height := imgImages.Height;       // ustawienie wysokosci obrazka

        imgBackground.Draw(Obrazy[i].Canvas, 0, 0, 0, True);  // narysowanie obrazka na TImage

        Transparent := True;              // rysunek przezroczysty
        Tag := -1;                        // ustawienie znacznika
        // znacznik Tag jest uzywany do rozpoznania jaki rysunek jest na TImage
        // -1 oznacza ze nie ma jeszcze rysunku
        // 0..139 numery rysunkow z komponentu imgImages
      end;
      inc(i);
    end;
    MozeUstawic := True;

    // losowanie rysunkow i polorzenia par na planszy:

    IlePar := (PoziomGry * PoziomGry) div 2;  // obliczenie ilosci par

    for i := 1 to IlePar do begin
      r := Random(imgImages.Count);  // wybranie losowego rysunku i wpisanie do r

      while SprawdzObrazek(r) do     // jezeli sie powtarza to dalej losuje rysunek
        r := Random(imgImages.Count);


      // wstawianie pary obrazkow na plansze
      for j := 1 to 2 do begin
        n := Random(PoziomGry * PoziomGry);   // wylosowanie pozycji na planszy

        while Obrazy[n].Tag <> -1 do begin    // jezeli pozycja jest juz zajeta to szukaj nastepnej wolnej
          inc(n);
          if n = Length(Obrazy) then
            n := 0;
        end;

        Obrazy[n].Tag := r;      // wstawienie rysunku na plansze;
      end;
    end;
end;

procedure TfrmGame.FormCreate(Sender: TObject);
begin
  // ustawienie parametrow poczatkowych

  Screen.Cursors[100] := LoadCursor(hInstance, 'HAND');
  Randomize;             // uruchomienie generatora liczb losowych
  KtoryWybrany := 0;
  PoziomGry := 4;
  InicjacjaObrazow;
  WyswietlCzas;
end;

procedure TfrmGame.UsunObrazy;
var
  i: Integer;
begin
  MozeUstawic := False;  // kiedy obrazki sa usuniete, nie moga byc wyswietlane na ekranie
  i := 0;
  while i < Length(Obrazy) do begin
    Obrazy[i].Free;      // usuwanie obrazka z pamieci
    inc(i);
  end;
  SetLength(Obrazy, 0);  // zwalnianie dynamicznej tablicy
end;

procedure TfrmGame.mnuSredniClick(Sender: TObject);
begin
  // usuniecie "haczyka" przy wszystkich menu

  Screen.Cursor := crHourGlass;
  try
      mnuNiski.Checked := False;
      mnuSredni.Checked := False;
      mnuNormaly.Checked := False;
      mnuWysoki.Checked := False;

      // wstawienie "haczyka" przy menu ktore zostalo klikniete
      (Sender as TMenuItem).Checked := True;

      // ustawnienie poziomy gry na podstawie Tag'u menu
      PoziomGry := (Sender as TMenuItem).Tag;

      // ustawienie poziomu gry
      UsunObrazy;
      pbxBackground.Repaint;
      InicjacjaObrazow;

      // ustawienie obrazkow na srodku
      FormResize(Self);
   finally
     Screen.Cursor := crDefault;
   end;
end;

procedure TfrmGame.mnuWyjcieClick(Sender: TObject);
begin
  Close;  // zamkniecie programu
end;

procedure TfrmGame.WybranyObraz(Sender: TObject);
var
  i: Integer;

begin

  // jezeli obrazek zostal nacisniety to jest pokazywany na ekranie
  with Sender as TImage do begin
    WybraneObrazy[KtoryWybrany] := Sender as TImage;  // zapamietywany jest wybrany obrazek w tablicy
    Canvas.FillRect(ClientRect);
    imgImages.Draw(Canvas, 0, 0, Tag , True);
    Repaint;
    OnClick := nil;              // usuwana jest procedura klikniecia (tak ze nie mozna w niego juz kliknac
    Cursor := crDefault;         // ustawiany jest kursor na normaly
    Inc(KtoryWybrany);         // zliczenie ile jest wybranych obrazow
    PlayWAV('PUSH');
  end;

  if KtoryWybrany = 2 then begin   // jezeli sa juz pokazane 2 obrazki to ...
    KtoryWybrany := 0;             // wyzerowanie miejsce
    Inc(IloscOdkryc);                // zwiekszenie liczby odkryc par

    if WybraneObrazy[0].Tag <> WybraneObrazy[1].Tag then begin // jezeli nie sa to te same obrazki to ...
      Sleep(500);                                              // poczekaj 0,5 sekundy
      PlayWAV('WAV03');
      for i := 0 to 1 do                                       // i schowaj obrazki
        with WybraneObrazy[i] do begin
          Canvas.FillRect(ClientRect);
          imgBackground.Draw(Canvas, 0, 0, 0 , True);          // zmiana obrazka na tlo
          Repaint;
          OnClick := WybranyObraz;                             // przywrocenie procedury obslugi klikniecia w obrazek
          Cursor := 100;                               // ustawienie kursora "reka"
        end;
    end
    else begin                                                      // w przeciwnym wypadku sa to takie same obrazki i...
      inc(IloscZnalezionych);                                  // zwiekszana jest liczba znalezionych par
      PlayWAV('OK');
    end;

  end;
end;

procedure TfrmGame.mnuAboutClick(Sender: TObject);
begin
  frmInfo.ShowModal;  // pokazuje okienko "o programie"
end;

procedure TfrmGame.timTimerTimer(Sender: TObject);
var
  j: Integer;

begin
  LicznikCzasu := GetTickCount - CzasStart; // obliczenie ilosc milisekund od poczatku gry
  WyswietlCzas;

  // sprawdzenie czy koniec gry
  if IloscZnalezionych = PoziomGry * PoziomGry div 2 then begin  // jezeli koniec gry to ...
//  begin
    timTimer.Enabled := False;  // wylaczenie licznika czasu
    PlayWAV('END');

    for j := 0 to 4 do begin   // koncowe miganie calego obrazu
      Application.ProcessMessages;
      pbxBackground.BringToFront;
      Sleep(250);

      Application.ProcessMessages;
      pbxBackground.SendToBack;
      Sleep(250);
    end;

    // informacja o koncu gry
//    MessageDlg('Gratulacje, odkry³eœ wszystkie pary obrazków w czasie: ' + lblLicznikCzasu.Caption, mtInformation, [mbOk], 0);

    mnuZakoncz.Click; // zakonczenie gry
  end;

end;

procedure TfrmGame.WyswietlCzas;
var
  i: Int64;
  s, m, h: Word;

  // funkcja dodaje 0 jezeli liczba jest jedno cyfrowa
  function Zero(S: String): String;
  begin
    Result := S;
    if Length(S) = 1 then
      Result := '0' + Result;
  end;

begin
  i := LicznikCzasu div 1000;    // przypisanie do i ilosci sekund (Licznik Czasu zawiera ilosc milisekund od poczatku gry)
  s := i mod 60;                 // wyliczenie sekund, minut, godzin
  m := (i div 60) mod 60;
  h := i div 3600;
  // i wyswietlenie w odpowiednich labelkach
//  lblLicznikCzasu.Caption := Zero(IntToStr(h)) + ':' + Zero(IntToStr(m)) +  ':' + Zero(IntToStr(s));
//  lblLiczbaOdkryc.Caption := IntToStr(IloscOdkryc);
end;

procedure TfrmGame.mnuNowaGraClick(Sender: TObject);
var
  i: Integer;

begin
  // ustawienie wszystkich menu i zmiennych do rozpoczecia gry
  IloscOdkryc := 0;
  KtoryWybrany := 0;
  IloscZnalezionych := 0;
  CzasStart := GetTickCount;
  timTimer.Enabled := True;
  mnuAbout.Enabled := False;
  mnuLevel.Enabled := False;
  mnuNowaGra.Enabled := False;
  mnuZakoncz.Enabled := True;
  WyswietlCzas;
//  lblLicznikCzasu.Show;
//  lblCzas.Show;
//  lblOdkrycia.Show;
//  lblLiczbaOdkryc.Show;

  // przypisanie kazdemu obrazkowi procedury klikniecia i kursora "reka"
  for i := 0 to Length(Obrazy) - 1 do
    with Obrazy[i] do begin
      OnClick := WybranyObraz;
      Cursor := 100;
    end;
end;

procedure TfrmGame.mnuZakonczClick(Sender: TObject);
begin
  // zakonczenie gry
  // ustawienie wszystkich menu, schowanie czasu i okryc itd...
//  lblLicznikCzasu.Hide;
//  lblCzas.Hide;
//  lblOdkrycia.Hide;
//  lblLiczbaOdkryc.Hide;

  LicznikCzasu := 0;
  IloscZnalezionych := 0;
  WyswietlCzas;
  timTimer.Enabled := False;
  mnuZakoncz.Enabled := False;
  mnuAbout.Enabled := True;
  mnuLevel.Enabled := True;
  mnuNowaGra.Enabled := True;
  UsunObrazy;
  InicjacjaObrazow;
  FormResize(Self);
end;

procedure TfrmGame.FormResize(Sender: TObject);
var
  x, y, i, w, h: Integer;

begin

  // ustawienie obrazkow na srodku formularza

  if MozeUstawic then begin  // sprawdza czy obrazki sa utworzone i czy moze je ustawic na srodku
    i := 0;
    for y := 0 to PoziomGry - 1 do
      for x := 0 to PoziomGry - 1 do begin
        with Obrazy[i] do begin
          w := (imgImages.Width + ODSTEP) * PoziomGry;
          h := (imgImages.Height + ODSTEP) * PoziomGry;
          Left := frmGame.Width div 2 - w div 2 + X * (imgImages.Width + ODSTEP);
//          Left := (frmGame.ClientHeight div 2 - w div 2)  + X * (imgImages.Width + ODSTEP);
          Top := frmGame.ClientHeight div 2 - h div 2 + Y * (imgImages.Height + ODSTEP) + 10;
        end;
        inc(i)
      end;
  end;


end;

procedure TfrmGame.FormConstrainedResize(Sender: TObject; var MinWidth, MinHeight, MaxWidth, MaxHeight: Integer);
begin
  // ustalenie minimalnego rozmiaru formularza
    MinWidth := (imgImages.Width + ODSTEP) * (PoziomGry + 1) + 100;
  MinHeight := MinWidth + 10;
end;

procedure TfrmGame.PlayWAV(Name: String);
var d: DWORD;
begin
  d := SND_RESOURCE {OR SND_FILENAME }or SND_ASYNC;
  PlaySound(PChar(Name), hInstance, d);
end;

procedure TfrmGame.pbxBackgroundPaint(Sender: TObject);
begin
  DrawTiled;
//  DrawStretched;
//  DrawCentered;
end;

procedure TfrmGame.DrawTiled;
var
  Row, Col: Integer;
  CR, IR: TRect;
  NumRows, NumCols: Integer;
begin
  CR := pbxBackground.ClientRect;
  IR := FPicture.ClientRect;
  NumRows := CR.Bottom div IR.Bottom;
  NumCols := CR.Right div IR.Right;
  with FPicture do
    for Row := 0 to NumRows + 1 do
      for Col := 0 to NumCols + 1 do
        BitBlt(pbxBackground.Canvas.Handle, Col * Picture.Width, Row * Picture.Height,
          Picture.Width, Picture.Height, Picture.Bitmap.Canvas.Handle,
          0, 0, SRCCOPY);
end;


procedure TfrmGame.DrawStretched;
var
  CR: TRect;
begin
  CR := pbxBackground.ClientRect;
  StretchBlt(pbxBackground.Canvas.Handle, 0, 0, CR.Right, CR.Bottom,
    FPicture.Picture.Bitmap.Canvas.Handle, 0, 0,
    FPicture.Picture.Width, FPicture.Picture.Height, SRCCOPY);
end;

procedure TfrmGame.DrawCentered;
var
  CR: TRect;
begin
  CR := pbxBackground.ClientRect;
   with FPicture do
     BitBlt(pbxBackground.Canvas.Handle, ((CR.Right - CR.Left) - Picture.Width) div 2,
       ((CR.Bottom - CR.Top) - Picture.Height) div 2,
       Picture.Graphic.Width, Picture.Graphic.Height,
       Picture.Bitmap.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TfrmGame.pbxPanelPaint(Sender: TObject);
begin
{  with (Sender as TPaintBox) do begin

    Canvas.Brush.Style := bsClear;
    Canvas.Font.Style := [fsItalic];
    Canvas.Font.Size := 12;
    Canvas.TextOut(1, 10, 'punkty');
    Canvas.TextOut(1, 70, 'czas gry');
    Canvas.TextOut(1, 130, 'odkrycia');

    Canvas.Font.Style := [fsBold];
    Canvas.Font.Size := 14;
    Canvas.TextOut(1, 35, '123');
    Canvas.TextOut(1, 95, '00:00:43');
    Canvas.TextOut(1, 155, '24');

  end;}
end;

end.
