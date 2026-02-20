unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmMain = class(TForm)
    mmoLog: TMemo;
    pnlTop: TPanel;
    grpErrados: TGroupBox;
    btnErrado1: TButton;
    btnErrado2: TButton;
    grpSolucoes: TGroupBox;
    btnSolucao1: TButton;
    btnSolucao2: TButton;
    btnSolucao3: TButton;
    grpComFalha: TGroupBox;
    btnSolucao1Falha: TButton;
    btnSolucao2Falha: TButton;
    btnSolucao3Falha: TButton;
    btnLimpar: TButton;
    procedure FormCreate(ASender: TObject);
    procedure btnErrado1Click(ASender: TObject);
    procedure btnErrado2Click(ASender: TObject);
    procedure btnSolucao1Click(ASender: TObject);
    procedure btnSolucao2Click(ASender: TObject);
    procedure btnSolucao3Click(ASender: TObject);
    procedure btnSolucao1FalhaClick(ASender: TObject);
    procedure btnSolucao2FalhaClick(ASender: TObject);
    procedure btnSolucao3FalhaClick(ASender: TObject);
    procedure btnLimparClick(ASender: TObject);
  private
    procedure Log(const ATexto: string);
    procedure ExecutarExemplo(const ANumero: Integer);
  end;

var
  frmMain: TfrmMain;

implementation

uses
  ExemplosTryFinally, Test;

{$R *.dfm}

procedure TfrmMain.FormCreate(ASender: TObject);
begin
  GOnDestroyLog := procedure(const AMsg: string) begin Log(AMsg); end;
  Log('ReportMemoryLeaksOnShutdown = True - leaks serao reportados ao fechar o app');
  Log('=== Try-Finally: Protecting Two Objects - Marco Cantu ===');
  Log('Ref: https://blogs.embarcadero.com/try-finally-blocks-for-protecting-multiple-resources-in-delphi/');
  Log('');
end;

procedure TfrmMain.Log(const ATexto: string);
begin
  mmoLog.Lines.Add(ATexto);
  mmoLog.SelStart := Length(mmoLog.Text);
  mmoLog.SelLength := 0;
  SendMessage(mmoLog.Handle, EM_SCROLLCARET, 0, 0);
end;

procedure TfrmMain.ExecutarExemplo(const ANumero: Integer);
begin
  case ANumero of
    1: begin
         Log('Executando Errado 1 (A2 falha = memory leak de A1)...');
         ExemploErrado1_ComFalha_DemonstrarLeak;
         Log('(Nao deveria chegar aqui)');
       end;
    2: begin
         Log('Executando Errado 2 (A2 falha = Free em indefinido)...');
         ExemploErrado2_ComFalha_DemonstrarFreeIndefinido;
         Log('(Nao deveria chegar aqui)');
       end;
    3: begin
         Log('Executando Solucao 1 - Try Aninhados...');
         Solucao1_TryAninhados;
         Log('Concluido com sucesso.');
       end;
    4: begin
         Log('Executando Solucao 2 - A2 := nil...');
         Solucao2_A2Nil;
         Log('Concluido com sucesso.');
       end;
    5: begin
         Log('Executando Solucao 3 - Ambos nil...');
         Solucao3_AmbosNil;
         Log('Concluido com sucesso.');
       end;
    6: begin
         Log('Sol. 1: A2.Destroy falha - finally externo ainda executa A1.Free. PROTEGIDO!');
         Solucao1_ComFalha_Protegido;
       end;
    7: begin
         Log('Sol. 2: A2.Destroy falha - A1.Free nunca executa (mesmo finally). A1 VAZA!');
         Solucao2_ComFalha_Protegido;
       end;
    8: begin
         Log('Sol. 3: A2.Destroy falha - A1.Free nunca executa (mesmo finally). A1 VAZA!');
         Solucao3_ComFalha_Protegido;
       end;
  end;
end;

procedure TfrmMain.btnErrado1Click(ASender: TObject);
begin
  try
    ExecutarExemplo(1);
  except
    on LE: Exception do
    begin
      Log('Erro: ' + LE.ClassName + ': ' + LE.Message);
      Log('  [LEAK] A1 nunca foi destruido - A2.Create falhou antes do try, A1 ficou fora do finally');
      Log('  Ao fechar o app, ReportMemoryLeaksOnShutdown mostrara o leak detectado.');
    end;
  end;
  Log('');
end;

procedure TfrmMain.btnErrado2Click(ASender: TObject);
begin
  try
    ExecutarExemplo(2);
  except
    on LE: Exception do
    begin
      Log('Erro: ' + LE.ClassName + ': ' + LE.Message);
      Log('  [LEAK/RISCO] A2 nao inicializado - A2.Free em valor indefinido; A1 pode nao ter sido destruido');
      Log('  Ao fechar o app, ReportMemoryLeaksOnShutdown mostrara leaks (se houver).');
    end;
  end;
  Log('');
end;

procedure TfrmMain.btnSolucao1Click(ASender: TObject);
begin
  try
    ExecutarExemplo(3);
  except
    on LE: Exception do
      Log('Erro: ' + LE.ClassName + ': ' + LE.Message);
  end;
  Log('');
end;

procedure TfrmMain.btnSolucao2Click(ASender: TObject);
begin
  try
    ExecutarExemplo(4);
  except
    on LE: Exception do
      Log('Erro: ' + LE.ClassName + ': ' + LE.Message);
  end;
  Log('');
end;

procedure TfrmMain.btnSolucao3Click(ASender: TObject);
begin
  try
    ExecutarExemplo(5);
  except
    on LE: Exception do
      Log('Erro: ' + LE.ClassName + ': ' + LE.Message);
  end;
  Log('');
end;

procedure TfrmMain.btnSolucao1FalhaClick(ASender: TObject);
begin
  try
    ExecutarExemplo(6);
  except
    on LE: Exception do
    begin
      Log('Erro: ' + LE.ClassName + ': ' + LE.Message);
      Log('  [PROTEGIDO] A1 foi destruido - veja "[OK] A1.Destroy executado" acima');
    end;
  end;
  Log('');
end;

procedure TfrmMain.btnSolucao2FalhaClick(ASender: TObject);
begin
  try
    ExecutarExemplo(7);
  except
    on LE: Exception do
    begin
      Log('Erro: ' + LE.ClassName + ': ' + LE.Message);
      Log('  [LEAK] A1 NAO foi destruido! A1.Free nunca executou - estava no mesmo');
      Log('         finally que A2.Free; ao falhar A2.Destroy, o restante do bloco nao roda.');
      Log('  Ao fechar o app, ReportMemoryLeaksOnShutdown mostrara o leak de A1.');
    end;
  end;
  Log('');
end;

procedure TfrmMain.btnSolucao3FalhaClick(ASender: TObject);
begin
  try
    ExecutarExemplo(8);
  except
    on LE: Exception do
    begin
      Log('Erro: ' + LE.ClassName + ': ' + LE.Message);
      Log('  [LEAK] A1 NAO foi destruido! A1.Free nunca executou - estava no mesmo');
      Log('         finally que A2.Free; ao falhar A2.Destroy, o restante do bloco nao roda.');
      Log('  Ao fechar o app, ReportMemoryLeaksOnShutdown mostrara o leak de A1.');
    end;
  end;
  Log('');
end;

procedure TfrmMain.btnLimparClick(ASender: TObject);
begin
  mmoLog.Clear;
end;

end.
