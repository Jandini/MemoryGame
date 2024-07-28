program Memory;

uses
  Forms,
  uMain in 'uMain.pas' {frmGame},
  uAbout in 'uAbout.pas' {frmInfo};

{$R GAME.RES}
{$R SOUND.RES}

begin
  Application.Initialize;
  Application.Title := 'Memory 2.0';
  Application.CreateForm(TfrmGame, frmGame);
  Application.CreateForm(TfrmInfo, frmInfo);
  Application.Run;
end.
