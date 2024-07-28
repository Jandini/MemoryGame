unit uAbout;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TfrmInfo = class(TForm)
    imgIcon: TImage;
    lblInfo: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    bevInfo: TBevel;
    btnOk: TButton;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmInfo: TfrmInfo;

implementation

{$R *.DFM}

procedure TfrmInfo.FormCreate(Sender: TObject);
begin
  imgIcon.Picture.Icon := Application.Icon;
end;

end.
