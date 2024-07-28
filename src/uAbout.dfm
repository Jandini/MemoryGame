object frmInfo: TfrmInfo
  Left = 247
  Top = 193
  BorderStyle = bsDialog
  Caption = 'O programie...'
  ClientHeight = 148
  ClientWidth = 288
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object imgIcon: TImage
    Left = 16
    Top = 16
    Width = 32
    Height = 32
  end
  object lblInfo: TLabel
    Left = 56
    Top = 16
    Width = 44
    Height = 13
    Caption = 'Memory'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label1: TLabel
    Left = 16
    Top = 64
    Width = 257
    Height = 33
    AutoSize = False
    Caption = 
      'Gra polega na odnalezieniu wszystkich par obrazów znajduj¹cych s' +
      'iê na planszy w jak najkrótszym czasie.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object Label2: TLabel
    Left = 56
    Top = 34
    Width = 153
    Height = 13
    Caption = 'Autor programu: Mateusz Janda '
  end
  object bevInfo: TBevel
    Left = 16
    Top = 56
    Width = 257
    Height = 9
    Shape = bsTopLine
  end
  object Label3: TLabel
    Left = 8
    Top = 128
    Width = 87
    Height = 13
    Caption = 'mat@elzab.com.pl'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object btnOk: TButton
    Left = 203
    Top = 113
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
end
