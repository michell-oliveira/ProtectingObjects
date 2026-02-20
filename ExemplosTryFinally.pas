unit ExemplosTryFinally;

interface

uses
  System.SysUtils,
  Test;

  procedure ExemploErrado1_LeakDeA1SeA2Falhar;
  procedure ExemploErrado2_FreeEmObjetoNaoInicializado;
  procedure ExemploErrado1_ComFalha_DemonstrarLeak;
  procedure ExemploErrado2_ComFalha_DemonstrarFreeIndefinido;
  procedure Solucao1_TryAninhados;
  procedure Solucao2_A2Nil;
  procedure Solucao3_AmbosNil;
  procedure Solucao1_ComFalha_Protegido;
  procedure Solucao2_ComFalha_Protegido;
  procedure Solucao3_ComFalha_Protegido;

implementation

{ ============================================================================
  CASO ERRADO 1: Memory Leak se A2.Create falhar
  Problema: Se a criação de A2 falhar, A1 permanece na memória (nunca é liberado)
  Referência: https://blogs.embarcadero.com/try-finally-blocks-for-protecting-multiple-resources-in-delphi/
  ============================================================================ }
procedure ExemploErrado1_LeakDeA1SeA2Falhar;
var
  LA1, LA2: TTest;
begin
  LA1 := TTest.Create('A1');
  LA2 := TTest.Create('A2');  // Se isso falhar (exceção), LA1 nunca é Free!
  try
    LA1.DoSomething;
    LA2.DoSomethingWith(LA1);
  finally
    LA2.Free;
    LA1.Free;
  end;
end;

{ ============================================================================
  CASO ERRADO 2: Free em objeto não inicializado
  Problema: Se A2.Create falhar, o bloco finally tenta A2.Free em variável
  não inicializada (valor indefinido). Pode causar acesso inválido à memória.
  Referência: https://blogs.embarcadero.com/try-finally-blocks-for-protecting-multiple-resources-in-delphi/
  ============================================================================ }
procedure ExemploErrado2_FreeEmObjetoNaoInicializado;
var
  LA1, LA2: TTest;
begin
  LA1 := TTest.Create('A1');
  try
    LA2 := TTest.Create('A2');  // Se isso falhar, LA2 fica com valor indefinido!
    LA1.DoSomething;
    LA2.DoSomethingWith(LA1);
  finally
    LA2.Free;  // PERIGO: LA2 pode não ter sido inicializado!
    LA1.Free;
  end;
end;

{ ============================================================================
  SOLUÇÃO 1: Try-Finally Aninhados (Nested Try Blocks)
  Vantagens: Muito claro e correto. Cada recurso protegido individualmente.
  Desvantagens: Mais verboso, aninhamento adicional com muitos recursos.
  ============================================================================ }
procedure Solucao1_TryAninhados;
var
  LA1, LA2: TTest;
begin
  LA1 := TTest.Create('A1');
  try
    LA2 := TTest.Create('A2');
    try
      LA1.DoSomething;
      LA2.DoSomethingWith(LA1);
    finally
      LA2.Free;
    end;
  finally
    LA1.Free;
  end;
end;

{ ============================================================================
  SOLUÇÃO 2: Inicializar apenas A2 com nil
  Vantagens: Menos linhas, menor custo de runtime.
  Desvantagens: Código "desbalanceado" - apenas A2 inicializado com nil.
  Observação: Free em nil não tem efeito em Delphi.
  ============================================================================ }
procedure Solucao2_A2Nil;
var
  LA1, LA2: TTest;
begin
  LA1 := TTest.Create('A1');
  LA2 := nil;  // Protege contra Free de variável não inicializada
  try
    LA2 := TTest.Create('A2');
    LA1.DoSomething;
    LA2.DoSomethingWith(LA1);
  finally
    LA2.Free;  // Seguro: Free em nil não faz nada
    LA1.Free;
  end;
end;

{ ============================================================================
  SOLUÇÃO 3: Inicializar ambos A1 e A2 com nil (mais balanceado)
  Vantagens: Mais limpo, balanceado, consistente e legível.
  A atribuição A1 := nil é tecnicamente supérflua (já que A1 := Create vem
  logo depois), mas oferece uniformidade - útil quando há 3, 4 ou mais recursos.
  ============================================================================ }
procedure Solucao3_AmbosNil;
var
  LA1, LA2: TTest;
begin
  LA1 := nil;
  LA2 := nil;
  LA1 := TTest.Create('A1');
  try
    LA2 := TTest.Create('A2');
    LA1.DoSomething;
    LA2.DoSomethingWith(LA1);
  finally
    LA2.Free;
    LA1.Free;
  end;
end;

{ Demonstra Errado 1: Quando A2 falha, A1 fica em memória (memory leak) }
procedure ExemploErrado1_ComFalha_DemonstrarLeak;
var
  LA1: TTest;
  LA2: TTestQueFalhaNoCreate;
begin
  LA1 := TTest.Create('A1');
  LA2 := TTestQueFalhaNoCreate.Create('A2');  // Levanta exceção - LA1 nunca Free!
  try
    LA1.DoSomething;
    LA2.DoSomethingWith(LA1);
  finally
    LA2.Free;
    LA1.Free;
  end;
end;

{ Demonstra Errado 2: Quando A2 falha, finally tenta Free em A2 não inicializado }
procedure ExemploErrado2_ComFalha_DemonstrarFreeIndefinido;
var
  LA1: TTest;
  LA2: TTest;  { Nao inicializado - valor indefinido se Create falhar }
begin
  LA1 := TTest.Create('A1');
  try
    LA2 := TTestQueFalhaNoCreate.Create('A2');  // Levanta exceção - LA2 indefinido
    LA1.DoSomething;
    LA2.DoSomethingWith(LA1);
  finally
    LA2.Free;  // Acesso inválido!
    LA1.Free;
  end;
end;

{ Soluções com falha no DESTROY de A2 - apenas Try Aninhado protege A1!
  Quando A2.Free falha (Destroy levanta), no padrão flat A1.Free nunca executa (A1 vaza).
  No try aninhado, o finally externo executa e A1.Free é chamado com sucesso. }
procedure Solucao1_ComFalha_Protegido;
var
  LA1: TTest;
  LA2: TTestQueFalhaNoDestroy;
begin
  LA1 := TTest.Create('A1');
  try
    LA2 := TTestQueFalhaNoDestroy.Create('A2');
    try
      LA1.DoSomething;
      LA2.DoSomethingWith(LA1);
    finally
      LA2.Free;  // Levanta EInvalidOperation - mas finally externo ainda roda!
    end;
  finally
    LA1.Free;   // Executado - LA1 liberado corretamente
  end;
end;

procedure Solucao2_ComFalha_Protegido;
var
  LA1: TTest;
  LA2: TTestQueFalhaNoDestroy;
begin
  LA1 := TTest.Create('A1');
  LA2 := nil;
  try
    LA2 := TTestQueFalhaNoDestroy.Create('A2');
    LA1.DoSomething;
    LA2.DoSomethingWith(LA1);
  finally
    LA2.Free;   // Levanta - LA1.Free NUNCA executa! LA1 vaza
    LA1.Free;
  end;
end;

procedure Solucao3_ComFalha_Protegido;
var
  LA1: TTest;
  LA2: TTestQueFalhaNoDestroy;
begin
  LA1 := nil;
  LA2 := nil;
  LA1 := TTest.Create('A1');
  try
    LA2 := TTestQueFalhaNoDestroy.Create('A2');
    LA1.DoSomething;
    LA2.DoSomethingWith(LA1);
  finally
    LA2.Free;   // Levanta - LA1.Free NUNCA executa! LA1 vaza
    LA1.Free;
  end;
end;

end.
