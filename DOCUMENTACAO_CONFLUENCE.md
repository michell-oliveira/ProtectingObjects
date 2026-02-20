# Proteção de Múltiplos Recursos em Delphi

**Versão:** 1.0  
**Data:** 2025  
**Referência:** [Try-Finally Blocks for Protecting Multiple Resources in Delphi](https://blogs.embarcadero.com/try-finally-blocks-for-protecting-multiple-resources-in-delphi/) — Marco Cantù, Embarcadero

---

## 1. Objetivo do documento

Este documento descreve as práticas corretas e incorretas para proteção de múltiplos recursos (objetos) em Delphi, quando há risco de exceções durante criação ou destruição. Inclui análise de cada abordagem, exemplos de código e demonstração prática através do projeto **ProtectingTwoObjects**.

---

## 2. Contexto e problema

### 2.1 O cenário

Em Delphi, ao alocar dois ou mais objetos que precisam ser liberados (`Free`), surge a questão: **como garantir que todos sejam liberados mesmo quando ocorre uma exceção?**

Recursos podem falhar em dois momentos:
- **Durante a criação** (`Create`): se o segundo objeto falhar ao ser criado, o primeiro já foi alocado e pode ficar sem liberação.
- **Durante a destruição** (`Destroy`): se o primeiro `Free` levantar exceção, o segundo `Free` no mesmo bloco `finally` pode nunca executar.

### 2.2 Por que isso importa

| Consequência | Impacto |
|--------------|---------|
| Memory leak | Objetos não liberados consomem memória; em processos longos, pode levar a falha por falta de memória. |
| Acesso inválido | Chamar `Free` em referência não inicializada pode gerar Access Violation. |
| Comportamento indefinido | Variáveis locais não inicializadas possuem valor indefinido; operações com elas são imprevisíveis. |

---

## 3. Casos incorretos (como não fazer)

### 3.1 Caso 1: Memory leak quando A2.Create falha

**Problema:** Ambos os objetos são criados antes do bloco `try`. Se a criação de A2 falhar, A1 nunca entra no fluxo protegido pelo `finally` e nunca é liberado.

```pascal
LA1 := TTest.Create('A1');
LA2 := TTest.Create('A2');  // Se falhar aqui, LA1 nunca é Free!
try
  LA1.DoSomething;
  LA2.DoSomethingWith(LA1);
finally
  LA2.Free;
  LA1.Free;
end;
```

**Resultado esperado no demo:** Exceção capturada. Mensagem `[LEAK] A1 nunca foi destruido`. Ao fechar o app, `ReportMemoryLeaksOnShutdown` reporta o leak.

---

### 3.2 Caso 2: Free em variável não inicializada

**Problema:** A2 é criado dentro do `try`. Se `Create` falhar, LA2 fica com valor indefinido (não inicializada). O `finally` tenta `LA2.Free`, o que pode causar Access Violation ou comportamento indefinido.

```pascal
LA1 := TTest.Create('A1');
try
  LA2 := TTest.Create('A2');  // Se falhar, LA2 indefinido
  LA1.DoSomething;
  LA2.DoSomethingWith(LA1);
finally
  LA2.Free;  // PERIGO: LA2 pode não ter sido inicializado
  LA1.Free;
end;
```

**Resultado esperado no demo:** Exceção capturada. Mensagem `[LEAK/RISCO] A2 não inicializado`.

---

## 4. Soluções corretas (padrões sem falha nos objetos)

Quando **não** há exceção na criação ou no `Destroy`, as três abordagens abaixo funcionam corretamente.

### 4.1 Solução 1: Try-Finally aninhados (Nested Try Blocks)

Cada recurso possui seu próprio bloco `try-finally`. O `finally` mais interno protege A2; o mais externo protege A1.

```pascal
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
```

| Aspecto | Descrição |
|---------|-----------|
| **Vantagens** | Clareza, correção garantida, cada recurso protegido isoladamente. |
| **Desvantagens** | Mais linhas, aninhamento aumenta com muitos recursos. |
| **Uso recomendado** | Código legado, quando não é possível usar interfaces. |

---

### 4.2 Solução 2: Inicializar apenas A2 com nil

Inicializar A2 com `nil` antes do `try` evita chamar `Free` em referência indefinida se a criação de A2 falhar. Em Delphi, `Free` em `nil` não tem efeito.

```pascal
LA1 := TTest.Create('A1');
LA2 := nil;
try
  LA2 := TTest.Create('A2');
  LA1.DoSomething;
  LA2.DoSomethingWith(LA1);
finally
  LA2.Free;
  LA1.Free;
end;
```

| Aspecto | Descrição |
|---------|-----------|
| **Vantagens** | Menos linhas, menor custo em tempo de execução. |
| **Desvantagens** | Padrão um pouco desbalanceado (só A2 inicializado com nil). |

---

### 4.3 Solução 3: Inicializar ambos com nil

Padrão simétrico, útil quando há vários recursos. Facilita a leitura e evita esquecimento ao adicionar novos objetos.

```pascal
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
```

| Aspecto | Descrição |
|---------|-----------|
| **Vantagens** | Padrão uniforme, escalável para 3, 4 ou mais recursos. |
| **Observação** | `LA1 := nil` é sobrescrito logo em seguida, mas mantém consistência. |

---

## 5. Falha no Destroy: teste decisivo

Quando o **Destroy** do primeiro objeto (A2) levanta exceção, o comportamento das soluções 2 e 3 se torna incorreto, pois A1.Free nunca é executado.

### 5.1 Por que soluções 2 e 3 falham

O `finally` é um único bloco. Se `LA2.Free` executar e o `Destroy` de LA2 levantar exceção, o restante do `finally` não é executado. Assim, `LA1.Free` nunca é chamado e ocorre memory leak de A1.

### 5.2 Resultados por solução (com falha no Destroy de A2)

| Solução | Proteção | Motivo |
|---------|----------|--------|
| **Try aninhado** | ✓ Protegido | `LA2.Free` está em um `finally` interno. Ao falhar, o `finally` externo ainda roda e executa `LA1.Free`. |
| **A2 := nil** | ✗ Leak | LA2.Free e LA1.Free no mesmo `finally`. Se LA2.Free falhar, LA1.Free não executa. |
| **Ambos nil** | ✗ Leak | Mesmo motivo da solução 2. |

### 5.3 Código da solução com try aninhado (protegida)

```pascal
LA1 := TTest.Create('A1');
try
  LA2 := TTestQueFalhaNoDestroy.Create('A2');
  try
    LA1.DoSomething;
    LA2.DoSomethingWith(LA1);
  finally
    LA2.Free;  // Levanta EInvalidOperation
  end;
finally
  LA1.Free;   // Ainda é executado
end;
```

---

## 6. Solução com interface (reference counting)

Uso de interfaces (`ITest`) com classes descendentes de `TInterfacedObject` elimina a necessidade de `try-finally` manual. O gerenciamento de memória é feito pelo reference counting do Delphi.

### 6.1 Funcionamento

- Ao atribuir um objeto a uma variável do tipo interface, a referência é incrementada.
- Quando a variável sai de escopo (fim da procedure, exceção, etc.), a referência é decrementada.
- Quando o contador chega a zero, o objeto é destruído automaticamente.

### 6.2 Exemplo com método New

```pascal
procedure SolucaoInterface_Normal;
var
  LA1, LA2: ITest;
begin
  LA1 := TTestInterface.New('A1');
  LA2 := TTestInterface.New('A2');
  LA1.DoSomething;
  LA2.DoSomethingWith(LA1);
  // Sem try-finally. Ao sair, LA1 e LA2 são liberados automaticamente.
end;
```

### 6.3 Comportamento em caso de exceção

Mesmo quando uma exceção ocorre no meio da procedure, as variáveis locais (LA1, LA2) saem de escopo e o reference counting libera os objetos. Não há necessidade de `try-finally` nem de tratamento especial.

### 6.4 Método New (factory)

O método de classe `New` cria o objeto e retorna a interface, encapsulando o `Create`:

```pascal
class function TTestInterface.New(const AName: string = ''): ITest;
begin
  Result := Create(AName);
end;
```

---

## 7. Projeto ProtectingTwoObjects

### 7.1 Estrutura do projeto

| Arquivo | Descrição |
|---------|-----------|
| `ProtectingTwoObjects.dpr` | Programa principal, configura `ReportMemoryLeaksOnShutdown := True` |
| `MainForm.pas` / `MainForm.dfm` | Formulário principal com botões para cada cenário |
| `Test.pas` | Classes `TTest`, `TTestInterface`, interfaces e variantes que falham |
| `ExemplosTryFinally.pas` | Implementação dos procedimentos de demonstração |

### 7.2 Classes e interfaces

| Tipo | Descrição |
|------|-----------|
| `TTest` | Classe base para exemplos com objetos (sem interface) |
| `TTestQueFalhaNoCreate` | Falha no `Create` (EOutOfMemory) |
| `TTestQueFalhaNoDestroy` | Falha no `Destroy` (EInvalidOperation) |
| `ITest` | Interface para exemplos com reference counting |
| `TTestInterface` | Implementa `ITest`, oferece método `New` |

### 7.3 Mapeamento: botões → cenários

| # | Botão | Cenário | Resultado esperado |
|---|-------|---------|--------------------|
| 1 | Leak de A1 | Errado 1 | Leak de A1 |
| 2 | Free em indefinido | Errado 2 | Risco de AV e leak |
| 3 | Try Aninhados | Solução 1 (sem falha) | OK |
| 4 | A2 := nil | Solução 2 (sem falha) | OK |
| 5 | Ambos nil | Solução 3 (sem falha) | OK |
| 6 | Sol. 1 + falha | Solução 1 com Destroy falhando | A1 liberado |
| 7 | Sol. 2 + falha | Solução 2 com Destroy falhando | Leak de A1 |
| 8 | Sol. 3 + falha | Solução 3 com Destroy falhando | Leak de A1 |
| 9 | Interface - sem try-finally | Uso normal de interface | OK |
| 10 | Interface + exceção | Interface com exceção | Ambos liberados |

---

## 8. Conclusões e recomendações

### 8.1 Resumo

| Abordagem | Proteção completa | Observações |
|-----------|-------------------|-------------|
| Try-finally aninhado | ✓ | Funciona mesmo com falha no Destroy |
| A2 := nil / Ambos nil | ✗ (quando Destroy falha) | Adequado apenas quando não há exceção no Destroy |
| Interface | ✓ | Não exige `try-finally`; reference counting cuida da liberação |

### 8.2 Recomendações

1. **Novo código:** Preferir interfaces com `TInterfacedObject` e método `New` quando o modelo de design permitir.
2. **Código legado com objetos:** Usar **try-finally aninhado** para múltiplos recursos quando houver risco de exceção no `Create` ou no `Destroy`.
3. **Evitar:** Padrão flat (soluções 2 e 3) quando o `Destroy` dos objetos puder levantar exceção.
4. **Validação:** Utilizar `ReportMemoryLeaksOnShutdown := True` em desenvolvimento para detectar leaks.

### 8.3 Referências

- [Try-Finally Blocks for Protecting Multiple Resources in Delphi](https://blogs.embarcadero.com/try-finally-blocks-for-protecting-multiple-resources-in-delphi/) — Marco Cantù
- Projeto: ProtectingTwoObjects (repositório interno)
