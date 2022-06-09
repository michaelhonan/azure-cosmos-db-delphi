object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 438
  ClientWidth = 827
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  DesignSize = (
    827
    438)
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 8
    Top = 39
    Width = 811
    Height = 391
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object btnAzureSample: TButton
    Left = 8
    Top = 8
    Width = 98
    Height = 25
    Caption = 'Azure Sample'
    TabOrder = 1
    OnClick = btnAzureSampleClick
  end
end
