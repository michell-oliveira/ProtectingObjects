object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Protecting Two Objects - Try-Finally Demo'
  ClientHeight = 420
  ClientWidth = 520
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 520
    Height = 185
    Align = alTop
    TabOrder = 0
    object grpErrados: TGroupBox
      Left = 8
      Top = 8
      Width = 160
      Height = 110
      Caption = ' Casos Errados '
      TabOrder = 0
      object btnErrado1: TButton
        Left = 12
        Top = 24
        Width = 136
        Height = 25
        Caption = '1. Leak de A1'
        TabOrder = 0
        OnClick = btnErrado1Click
      end
      object btnErrado2: TButton
        Left = 12
        Top = 48
        Width = 136
        Height = 25
        Caption = '2. Free em indefinido'
        TabOrder = 1
        OnClick = btnErrado2Click
      end
    end
    object grpSolucoes: TGroupBox
      Left = 174
      Top = 8
      Width = 165
      Height = 110
      Caption = ' Solucoes Corretas '
      TabOrder = 1
      object btnSolucao1: TButton
        Left = 12
        Top = 24
        Width = 141
        Height = 25
        Caption = '3. Try Aninhados'
        TabOrder = 0
        OnClick = btnSolucao1Click
      end
      object btnSolucao2: TButton
        Left = 12
        Top = 50
        Width = 141
        Height = 25
        Caption = '4. A2 := nil'
        TabOrder = 1
        OnClick = btnSolucao2Click
      end
      object btnSolucao3: TButton
        Left = 12
        Top = 76
        Width = 141
        Height = 25
        Caption = '5. Ambos nil'
        TabOrder = 2
        OnClick = btnSolucao3Click
      end
    end
    object grpComFalha: TGroupBox
      Left = 345
      Top = 8
      Width = 165
      Height = 110
      Caption = ' Solucoes com Falha '
      TabOrder = 2
      object btnSolucao1Falha: TButton
        Left = 12
        Top = 24
        Width = 141
        Height = 25
        Caption = '6. Sol. 1 + falha'
        TabOrder = 0
        OnClick = btnSolucao1FalhaClick
      end
      object btnSolucao2Falha: TButton
        Left = 12
        Top = 50
        Width = 141
        Height = 25
        Caption = '7. Sol. 2 + falha'
        TabOrder = 1
        OnClick = btnSolucao2FalhaClick
      end
      object btnSolucao3Falha: TButton
        Left = 12
        Top = 76
        Width = 141
        Height = 25
        Caption = '8. Sol. 3 + falha'
        TabOrder = 2
        OnClick = btnSolucao3FalhaClick
      end
    end
    object btnLimpar: TButton
      Left = 8
      Top = 150
      Width = 75
      Height = 25
      Caption = 'Limpar'
      TabOrder = 3
      OnClick = btnLimparClick
    end
  end
  object mmoLog: TMemo
    Left = 0
    Top = 185
    Width = 520
    Height = 235
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
    WordWrap = False
  end
end
