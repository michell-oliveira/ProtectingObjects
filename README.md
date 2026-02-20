# ProtectingTwoObjects

Projeto Delphi de demonstração baseado no artigo de Marco Cantù:

**Try-Finally Blocks for Protecting Multiple Resources in Delphi**  
https://blogs.embarcadero.com/try-finally-blocks-for-protecting-multiple-resources-in-delphi/

## Estrutura do Projeto

- **ProtectingTwoObjects.dpr** – Programa principal
- **MainForm.pas/dfm** – Form principal com interface
- **TTest.pas** – Classe `TTest` usada nos exemplos
- **ExemplosTryFinally.pas** – Implementação dos exemplos

## Casos Errados (How NOT to Write the Code)

### 1. Errado 1: Memory Leak se A2.Create falhar
```pascal
A1 := TTest.Create;
A2 := TTest.Create;  // Se falhar, A1 nunca é liberado!
try
  A1.DoSomething;
  A2.DoSomethingWith(A1);
finally
  A2.Free;
  A1.Free;
end;
```

### 2. Errado 2: Free em objeto não inicializado
```pascal
A1 := TTest.Create;
try
  A2 := TTest.Create;  // Se falhar, A2 fica indefinido!
  A1.DoSomething;
  A2.DoSomethingWith(A1);
finally
  A2.Free;  // PERIGO: A2 pode não ter sido inicializado
  A1.Free;
end;
```

## Soluções Corretas (A Tale of Three Solutions)

### Solução 1: Try-Finally Aninhados
- Mais verboso, mas muito claro
- Cada recurso protegido individualmente

### Solução 2: A2 := nil
- Menos linhas e menor custo em runtime
- Código um pouco desbalanceado

### Solução 3: A1 := nil; A2 := nil
- Padrão mais balanceado e legível
- Uniforme para vários recursos

## Como Executar

1. Abra `ProtectingTwoObjects.dproj` no RAD Studio/Delphi
2. Compile e execute
3. Use os botões da interface:
   - **Casos Errados**: Demonstram os bugs quando A2.Create falha
   - **Soluções Corretas**: Padrões corretos sem falha
   - **Soluções com Falha**: Demonstram que os recursos são liberados corretamente
