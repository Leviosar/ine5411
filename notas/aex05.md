# Procedimentos

Antes de falar sobre o suporte da ISA do MIPS para procedimentos, vamos dar uma breve resumida sobre o que é um procedimento e qual sua utilidade prática. Um procedimento, é um trecho de código específico que recebe ou não parâmetros, executa uma computação e retorna valores. Na maior parte das linguagens de programação modernas esse conceito se mistura com o conceito de "Função" e ele também possui um paralelo forte com o conceito de "Método" da OOP. Esse tipo de estrutura é muito útil para evitar repetição constante de código e isolar uma funcionalidade do resto do sistema.

## Suporte para procedimentos na ISA do MIPS

### Registradores e instruções

O MIPS destina registradores reservados apenas para o fluxo de chamada e retorno de procedimentos. São 4 registradores para parâmetros `($a0, $a3)`, 2 para valores de retorno `($v0 e $v1)` e um registrador `($ra)` para guardar o endereço de retorno. Além disso existem duas instruções usadas muito para o suporte a procedimentos, `jal address` (jump and link) e `jr $ra` on address é uma label para a primeira instrução da procedure. A diferença de usar `jal` e usar um `j` comum é que o `jal` automaticamente atribui o valor de `PC+4` ao registrador `$ra` permitindo que se retorne para o local de chamada com facilidade.

> Caso o procedimento possua mais de 4 argumentos, esses terão que ser salvos na pilha de memória, veremos esse processo depois.

### Convenção de chamada

Existem algumas convenções adotadas para se escrever procedimentos no Assembly do MIPS, a primeira é utilizar aqueles registradores e instruções explicadas acima para fazer a chamada, mas ainda existem mais coisas. 

Primeiramente, uma procedure pode precisar utilizar registradores que contém um valor importante para o programa principal, por isso, os valores nesses registradores precisam ser salvos em memória no início da execução da rotina chamada e restaurados aos mesmos registradores ao final dessa execução. Esses registradores são salvos numa estrutura de pilha, utilizando o registrador $sp (stack pointer) que aponta para o topo da pilha de memória.

No caso do MIPS, a pilha cresce em direção a endereços menores, ou seja, sabemos que a pilha está cheia quando adicionamos algo no endereço 0 dessa pilha. Isso também significa que quando adicionamos um elemento decrementamos o $sp, quando removemos um elemento incrementamos o $sp. As operações da pilha são apenas duas e estão descritas abaixo:

```assembly
# Adiciona $t0 na pilha
addi $sp, $sp, -4
sw $t0, 0($sp)

# Adiciona $t1 na pilha
addi $sp, $sp, -4
sw $t1, 0($sp)

# Remove $t1 da pilha 
lw $t1, 0($sp)
addi $sp, $sp, 4

# Remove $t0 da pilha
lw $t0, 0($sp)
addi $sp, $sp, 4
```

É importante dizer que também existe outra parte dessa convenção: registradores do tipo `$tx` não são salvos pela rotina chamada e devem ser salvos pela rotina chamadora, enquanto os registradores do tipo `$sx` são salvos pela rotina chamada.

### Procedimentos aninhados

Tudo isso que vimos até agora é o suficiente para suportar procedimentos folha, que são as procedimentos que não chamam outros procedimentos. A situação muda quando precisamos dar suporte a procedimentos aninhados. Quando isso acontece precisamos tomar cuidados maiores.

- Rotina chamadora

Deve preservar os registradores de argumentos ($a0 a $a3) e temporários ($t0 a $t9) que for usar futuramente.

- Rotina chamada

Deve preservar os registradores salvos ($s0 a $s7) e o registrador de retorno ($ra) que for usar.

Para exemplificar isso, vamos fazer o processo de compilação de uma rotina aninhada, mais especificamente a rotina recursiva para o cálculo de um fatorial.

Código C:

```c
int fact(int n) {
    if (n < 1) return 1;
    else return (n * fact(n - 1));
}
```

```assembly
fact:
  addi $sp, $sp, -8     # Decrementa o endereço da pilha
  sw $ra, 4($sp)        # salva endereço de retorno
  sw $a0, 0($sp)        # salva parâmetro
  
  slti $t0, $a0, 1      # t0 =1, se n < 1
  beq $t0, $zero, L1    # se n >= 1, vá para L1
  
  addi $v0, $zero, 1    # retorna valor 1
  addi $sp, $sp, 8      # remove dois itens da pilha
  jr $ra                # retorna para depois de jal

L1:
  addi $a0, $a0, -1     # novo argumento é n-1
  jal fact              # fact é re-invocada

  lw $a0, 0($sp)        # restaura argumento n
  lw $ra, 4($sp)        # restaura endereço de retorno
  addi $sp, $sp, 8      # remove dois itens da pilha
  
  mul $v0, $a0, $v0     # retorna o produto
  jr $ra                # retorna à chamadora
```