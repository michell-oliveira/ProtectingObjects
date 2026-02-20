unit Test;

interface

uses
  System.Classes,
  System.SysUtils;

type
  TLogProc = reference to procedure(const AMsg: string);

  TTest = class
  private
    FName: string;
  public
    constructor Create(const AName: string = ''); overload;
    destructor Destroy; override;
    procedure DoSomething;
    procedure DoSomethingWith(const AOther: TTest);
    property Name: string read FName write FName;
  end;

  { Classe que levanta exceção no Create - para demonstrar os bugs dos casos errados }
  TTestQueFalhaNoCreate = class(TTest)
  public
    constructor Create(const AName: string = ''); reintroduce;
  end;

  { Classe que levanta exceção no Destroy - demonstra que apenas try aninhado protege }
  TTestQueFalhaNoDestroy = class(TTest)
  public
    destructor Destroy; override;
  end;

var
  GOnDestroyLog: TLogProc;

implementation

{ TTest }

constructor TTest.Create(const AName: string);
begin
  inherited Create;
  FName := AName;
end;

destructor TTest.Destroy;
var
  LNome: string;
begin
  if Assigned(GOnDestroyLog) then
  begin
    LNome := FName;
    if LNome = '' then LNome := ClassName;
    GOnDestroyLog(Format('  [OK] %s.Destroy executado - objeto liberado', [LNome]));
  end;
  inherited;
end;

procedure TTest.DoSomething;
begin
  // Implementação de exemplo
end;

procedure TTest.DoSomethingWith(const AOther: TTest);
begin
  if Assigned(AOther) then
  begin
    // Implementação de exemplo usando o outro objeto
  end;
end;

{ TTestQueFalhaNoCreate }

constructor TTestQueFalhaNoCreate.Create(const AName: string);
begin
  inherited Create(AName);
  raise EOutOfMemory.Create('Simulando falha na criacao de A2');
end;

{ TTestQueFalhaNoDestroy }

destructor TTestQueFalhaNoDestroy.Destroy;
begin
  raise EInvalidOperation.Create('Simulando falha no Destroy');
  { inherited nao e executado - excecao propaga }
end;

end.
