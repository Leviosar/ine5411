# Capítulo 2 - Instructions: Language of the Computer

### 2.7

Show how the value `0xabcdef12` would be arranged in memory of a little-endian and a big-endian machine. Assume the data is stored starting at address 0.

**Resposta:**

Na representação little-endian vamos começar endereçando pelo byte menos significativo (12), enquanto no big-endian iremos representar a partir do byte mais significativo (ab)

- Little-endian

| Address | Data |
| ------- | ---- |
| 00      | 12   |
| 04      | ef   |
| 08      | cd   |
| 12      | ab   |

- Big-endian

| Address | Data |
| ------- | ---- |
| 00      | ab   |
| 04      | cd   |
| 08      | ef   |
| 12      | 12   |

### 2.9

Translate the following C code to MIPS. Assume that the variables f, g, h, i, and j are assigned to registers $s0, $s1, $s2, $s3, and $s4, respectively. Assume that the base address of the arrays A and B are in registers $s6 and $s7, respectively. Assume that the elements of the arrays A and B are 4-byte words: 

```c
B[8] = A[i] + A[j];
```

**Resposta:**

```assembly
sll $s3, $s3, 2     # Corrige o offset multiplicando por 4
add $t0, $s6, $s3   # $t0 = base A + i
lw $t1, 0($t0)      # $t1 = MEM[$t0]
sll $s4, $s4, 2     # Corrige o offset multiplicando por 4
add $t2, $s6, $s4   # $t2 = base A + j 
lw $t3, 0($t2)      # $t3 = MEM[$t2]
add $t4, $t1, $t2   # $t4 = A[i] + A[j]
sw $t4, 32($s7)     # MEM[$s7 + 32] = $t4
```

### 2.12

Assume that registers `$s0` and `$s1` hold the values `0x80000000` and `0xD0000000`, respectively. 

`$s0 = 1000 0000 0000 0000 0000 0000 0000 0000`
`$s1 = 1101 0000 0000 0000 0000 0000 0000 0000`

#### 2.12.1

What is the value of $t0 for the following assembly code? 

```assembly
add $t0, $s0, $s1
```

**Resposta:** o resultado da soma, é `0x150000000`, mas como o registrador representará no máximo 32 bits (ou 8 caracteres hexadecimais), temos `0x5000000`.

#### 2.12.2

Is the result in $t0 the desired result, or has there been overflow? 

**Resposta:** houve overflow

#### 2.12.3

For the contents of registers $s0 and $s1 as specified above, what is the value of $t0 for the following assembly code? 

```assembly
sub $t0, $s0, $s1
```

` s0 = 1000 0000 0000 0000 0000 0000 0000 0000`
`~s1 = 0010 1111 1111 1111 1111 1111 1111 1111`

**Resposta:** faremos a conta `$s0 - $s1`, mas na verdade o que queremos é `$s0 + (- $s1)`, e pra isso vamos encontrar o complemento de 2 de `$s1`.

```
1. 1101 0000 0000 0000 0000 0000 0000 0000 # negamos todos os bits
2. 0010 1111 1111 1111 1111 1111 1111 1111 # somamos 1 (vários carrys depois)
3. 0011 0000 0000 0000 0000 0000 0000 0000 # prontinho
```

Agora que já temos `-$s1`, podemos fazer `$s0 + (- $s1)`

```
    1000 0000 0000 0000 0000 0000 0000 0000
    +
    0011 0000 0000 0000 0000 0000 0000 0000
    ---------------------------------------
    1011 0000 0000 0000 0000 0000 0000 0000
```

Convertendo novamente pra hexadecimal temos `0xB000000`

#### 2.12.4

Is the result in $t0 the desired result, or has there been overflow? 

**Resposta:** não houve overflow.

#### 2.12.5

For the contents of registers $s0 and $s1 as specified above, what is the value of $t0 for the following assembly code? 

```assembly
add $t0, $s0, $s1 
add $t0, $t0, $s0 
```

Operação: (0x80000000 + 0xD0000000) + 0x80000000

**Resposta:** 
```
0x80000000
+
0xD0000000
----------
0x50000000
+
0x80000000
----------
0xD0000000
```

#### 2.12.6

Is the result in $t0 the desired result, or has there been overflow?

**Resposta:** houve overflow.

### 2.14

Provide the type and assembly language instruction for the following binary value: `0000 0010 0001 0000 1000 0000 0010 0000`

**Resposta:**

Podemos olhar para o começo e como os bits de 26-31 são `000000` já sabemos que é uma instrução do tipo R. Vamos então reformatar no formato de uma instrução do tipo R.

| opcode | rs    | rt    | rd    | shamt | funct  |
| ------ | ----- | ----- | ----- | ----- | ------ |
| 000000 | 10000 | 10000 | 10000 | 00000 | 100000 |

Os campos dos três registradores são iguais, e correspondem ao registrador `$16` ou `$s0`. E olhando para o campo `funct`, como ele é quebrado em `100` e `000` sabemos que é uma instrução `add`. Dessa forma, a resposta correta é: Uma instrução do tipo R, `add $s0, $s0, $s0`.

### 2.15

Provide the type and hexadecimal representation of following instruction: sw $t1, 32($t2)

**Resposta:** 

Agora temos o caminho inverso, teremos que transformar a instrução completa em binário, para depois transformar em hex. Nesse caso vamos formatar ela como uma instrução do tipo I. Por ser um `sw`, olhando no green sheet vemos que o opcode é `101011`, os registradores também são fáceis de codificar, seus números são respectivamente `$9` e `$10`, gerando `01001` e `01010`. Por último, a constante de deslocamento ocupa 16 bits e nesse caso é o número 32, gerando `0000000000100000` 

| opcode | rs    | rt    | const            |
| ------ | ----- | ----- | ---------------- |
| 101011 | 01001 | 01010 | 0000000000100000 |

O número completo em binário seria `1010 1101 0010 1010 0000 0000 0010 0000`, convertendo pra hex byte a byte temos `0xAD2A0020`.

### 2.17

Provide the type, assembly language instruction, and binary representation of instruction described by the following MIPS fields:

| opcode | rs  | rt  | const |
| ------ | --- | --- | ----- |
| 0x23   | 0x1 | 0x2 | 0x4   |

**Resposta:**

Primeiro convertemos campo a campo de hexa para binário, levando em consideração que como só foram dados aqueles quatro campos provavelmente é uma instrução do formato I.

| opcode | rs    | rt    | const            |
| ------ | ----- | ----- | ---------------- |
| 100011 | 00001 | 00010 | 0000000000000100 |

Olhando no ![Green sheet](https://inst.eecs.berkeley.edu/~cs61c/resources/MIPS_Green_Sheet.pdf) vemos que `100011` é o `opcode` para `lw` em instruções de formato I. Juntando com a informação que temos dos números de outros campos temos a instrução completa sendo `lw $v0, 4($at)` ou `lw $2, 4($1)`, lembrando que em instruções `lw` o `rt` é o campo de destino.

### 2.18

Assume that we would like to expand the MIPS register file to 128 registers and expand the instruction set to contain four times as many instructions.

#### 2.18.1

How this would this affect the size of each of the bit fields in the R-type instructions?

**Resposta:** cada campo de registrador deve poder endereçar cada um dos 128 registradores, isso faz com que precisamos de 7 bits por campo de registrador, aumentando em 2 bits cada campo ou 6 bits no total. Além disso, considerando que precisamos multiplicar o número de instruções por 4, temos que adicionar mais log₂(4) bits ao campo `opcode`, que agora ficará com 8 bits. No final, o tamanho formato de instruções iria de 32 bits para 40 bits.

| opcode | rs     | rt     | rd     | shamt  | funct  |
| ------ | ------ | ------ | ------ | ------ | ------ |
| 8 bits | 7 bits | 7 bits | 7 bits | 5 bits | 6 bits |

#### 2.18.2

How this would this affect the size of each of the bit fields in the I-type instructions?

**Resposta:** da mesma forma que no formato R, os campos que referenciam registradores devem ser aumentados para 7 bits, a mesma coisa acontece com o `opcode`. O campo de constante/endereço não precisa ser alterado.

| opcode | rs     | rt     | const   |
| ------ | ------ | ------ | ------- |
| 8 bits | 7 bits | 7 bits | 16 bits |

#### 2.18.3

How could each of the two proposed changes decrease the size of an MIPS assembly program? On the other hand, how could the proposed change increase the size of an MIPS assembly program?

**Resposta:** 

- *Diminuir o tamanho*: considerando que teriamos mais registradores, menos operações na pilha seriam feitas, então gastariamos menos instruções para realizar essas operações, resultando em um programa menor. Além disso, com o aumento da variedade de instruções, poderiamos ter novas instruções que realizam em uma única instrução operações que hoje fazemos em duas ou mais, também reduzindo o tamanho do código. Essa última consequência também poderia ser acompanhada de modificações no hardware.

- *Aumentar o tamanho*: como aumentamos o tamanho de instrução para 40 bits (instrução R com 40 bits e instrução I com 38, provavelmente seria arrendondado para cima para manter um padrão), o tamanho total do código em bits iria aumentar.  

### 2.19

Assume the following register contents:

```assembly
    $t0 = 0xAAAAAAAA, $t1 = 0x12345678
```

#### 2.19.1

For the register values shown above, what is the value of $t2 for the following sequence of instructions?

```assembly
sll $t2, $t0, 44 
or $t2, $t2, $t1
```

**Resposta**: `$t2` terá o valor de `$t1` (0x12345678), isso acontece porque na primeira instrução, é realizado um shift de 44 posições, deixando o registrador com o valor 0x00000000. Ao fazer uma operação OR do tipo `a | 0`, sempre teremos como resultado o valor de `a`, por isso na segunda instrução o valor de `$t1` é passado para `$t2`

#### 2.19.2 

For the register values shown above, what is the value of $t2 for the following sequence of instructions? 

```assembly
sll $t2, $t0, 4 
andi $t2, $t2, −1 
```

**Resposta**: Após a primeira instrução, teremos no registrador `$t2` o valor `0xAAAAAAA0`, já que o deslocamento de 4 bits ao ser representado em hexadecimal ocupa apenas um caractere. A segunda instrução faz um `andi` com o valor -1 (32 bits com o valor 1 considerando uma conversão para complemento de 2), e como temos que `a and 1 = a`, o valor final do registrador `$t2` é `0xAAAAAAA0`.

#### 2.19.3 

For the register values shown above, what is the value of $t2 for the following sequence of instructions? 

```assembly
srl $t2, $t0, 3 
andi $t2, $t2, 0xFFEF
```

**Resposta**: Ao converter `0xAAAAAAAA` para binário temos `10101010101010101010101010101010`, realizando um deslocamento à direita por 3 bits, ficaremos com `00010101010101010101010101010101` ou `0x15555555`.

Agora, convertemos a constante da segunda instrução `0x0000FFEF` para binário e temos `00000000000000001111111111101111`, realizado uma operação `and` entre os dois valores teremos o valor final de `00000000000000000101010101000101`, ou `0x00005545`.

### 2.21 

Provide a minimal set of MIPS instructions that may be used to implement the following pseudoinstruction:

```assembly
not $t1, $t2 // bit-wise invert
```

**Resposta**: utilizando a operação `nor`, nativa ao MIPS, podemos expressar uma negação bit-a-bit da seguinte forma: `not a = nor(a, a)`, escrevendo isso para uma instrução no assembly do MIPS teremos

```
nor $t1, $t2, $t2
```

### 2.22 

For the following C statement, write a minimal sequence of MIPS assembly instructions that does the identical operation. Assume `$t1 = A`, `$t2 = B`, and `$s1` is the base address of C.

```c
A = C[0] << 4;
```

**Resposta**: 

```assembly
lw $t1, 0($s1)
sll $t1, $t1, 4
```

### 2.24 

Suppose the program counter (PC) is set to 0x2000 0000. Is it possible to use the jump (j) MIPS assembly instruction to set the PC to the address as 0x4000 0000? Is it possible to use the branch-on-equal (beq) MIPS assembly instruction to set the PC to this same address?

```
A = 0x2000 0000 = 0010 0000 0000 0000 0000 0000 0000 0000
B = 0x4000 0000 = 0100 0000 0000 0000 0000 0000 0000 0000
```

**Resposta**: em nenhum dos dois casos é possível, o jump só consegue alterar os 28 LSBs do endereço, então não seria possível alterar os últimos 4 bits que são diferentes nos endereços. Enquanto no Branch, o alcance superior é de + 2^15, não suficiente para chegar no segundo endereço.

### 2.25 

Th e following instruction is not included in the MIPS instruction set:

```assembly
rpt $t2, loop # if(R[rs]>0) R[rs]=R[rs]−1, PC=PC+4+BranchAddr
```

#### 2.25.1 

If this instruction were to be implemented in the MIPS instruction set, what is the most appropriate instruction format?

**Resposta**: Formato I.

#### 2.25.2

What is the shortest sequence of MIPS instructions that performs the same operation?

**Resposta**:

```assembly
addi $t2, $t2, –1
beq $t2, $0, loop
```

### 2.26 

Consider the following MIPS loop: 

```assembly
LOOP: 
    slt $t2, $0, $t1 
    beq $t2, $0, DONE 
    subi $t1, $t1, 1 
    addi $s2, $s2, 2 
    j LOOP 
DONE: 
```

#### 2.26.1

Assume that the register $t1 is initialized to the value 10. What is the value in register $s2 assuming $s2 is initially zero? 

**Resposta**: o valor retornado pelo `slt` feito na primeira instrução é 1 (0 < 10), então logo abaixo no `beq` quando comparado com o valor de `$0`, a comparação será falsa e continuará executando `$t1 -= 1` e `$s0 += 2`. O valor final de `$s2` será 20 após 10 iterações do loop. 

#### 2.26.2 

For each of the loops above, write the equivalent C code routine. Assume that the registers $s1, $s2, $t1, and $t2 are integers A, B, i, and temp, respectively. 

**Resposta**:

```c
int i = 10;
int B = 0;
do {
    B += 2;
    i -= 1;
} while (i > 0)
```

#### 2.26.3

For the loops written in MIPS assembly above, assume that the register $t1 is initialized to the value N. How many MIPS instructions are executed?

**Resposta**: `5N + 2`

Como o loop possui 5 instruções, serão executadas todas elas N vezes durante a execução do programa, mas no momento onde `$t1` assumir o valor N+1, as duas primeiras instruções (`slt` e `beq`) ainda serão executadas antes do loop ser encerrado, por isso são adicionados 2 instruções ao cálculo final, tendo `5N + 2`.

### 2.31

Implement the following C code in MIPS assembly. What is the total number of MIPS instructions needed to execute the function? 

```c
int fib(int n) { 
    if (n==0) 
    {
        return 0;
    } 
    else if (n == 1)
    {
        return 1;
    } 
    else
    {
        return fib(n−1) + fib(n−2)
    };
}
```

```assembly
fib:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a0, 0($sp)

    slti $t0, $a0, 2
    beq $t0, $zero, Control

    add $v0, $v0, $a0
    add $sp, $sp, 8 
    jr $ra

Control:
    addi $a0, $a0, -1
    jal fib

    addi $a0, $a0, -1
    jal fib

    lw $a0 0($sp)
    lw $ra 4($sp)
    add $sp, $sp, 8
    jr $ra

```

### 2.34 

Translate function f into MIPS assembly language. If you need to use registers $t0 through $t7, use the lower-numbered registers first. Assume the function declaration for func is “int f(int a, int b);”. The code for function f is as follows:

```c
int f(int a, int b, int c, int d){
    return func(func(a,b),c+d);
}
```

```assembly
f:
  # Guarda na pilha os valores de $ra para o retorno
  # e os valores de $s0 e $s1 que serão usados
  addi $sp,$sp,-12
  sw $ra, 8($sp)
  sw $s1, 4($sp)
  sw $s0, 0($sp)

  # Coloca os valores recebidos por parâmetro em $s0 e $s1
  add $s1, $a2, $zero
  add $s0, $a3, $zero
  
  # Chama a função func com os argumentos a e b
  jal func
  
  # Move o retorno da chamada de jal func anterior para o primeiro registrador de parâmetro
  add $a0, $v0, $zero
  # Move o valor de c+d ($s0 + $s1) para o segundo registrador de parâmetro
  add $a1, $s0, $s1
  # Chama novamente a função
  jal func

  # Retorna para a chamadora
  jr $ra
```

### 2.39

Write the MIPS assembly code that creates the 32-bit constant `0010 0000 0000 0001 0100 1001 0010 0100` (base two) and stores that value to register $t1.

**Resposta:** essa atribuição precisa ser quebrada em duas instruções, a primeira instrução, `lui`, irá carregar os 16 bits mais significativos da constante no registrador, então convertendo `0010 0000 0000 0001` temos 8193. 

A segunda instrução, vai fazer um or imediato (`ori`) entre o valor atual de $t1 (que possui como 16 bits mais significativos o valor que colocamos na primeira instrução, e como 16 bits menos significativos o valor 0). Como `a or 0 = a`, no final temos a constante de 32 bits no registrador.

```assembly
lui $t1, 8193
ori $t1, $t1, 18724
```

### 2.40

If the current value of the PC is 0x00000000, can you use a single jump instruction to get to the PC address as shown in Exercise 2.39?

**Resposta:** o valor do exercício 2.39 era `0010 0000 0000 0001 0100 1001 0010 0100`, convertendo pra hexadecimal `0x2001 4924`, um salto de 29 bits, sendo que o valor máximo para o salto do `jump` é de 28 bits, então o endereço serial inalcançável.

Porém, utilizando-se de uma instrução do tipo jump, a `jr`, você pode alcançar os 32 bits de um

### 2.41 

If the current value of the PC is 0x00000600, can you use a single branch instruction to get to the PC address as shown in Exercise 2.39?

**Resposta:** utilizando-se dos mesmos valores, mas dessa vez com o range de 16 bits de um `branch`, também seria impossível alcançar essa instrução.

### 2.42

If the current value of the PC is 0x1FFFf000, can you use a single branch instruction to get to the PC address as shown in Exercise 2.39?

**Resposta:** partindo de `0x1fff f000` e adicionando o range máximo de um branch `+ 4 + 0x1FFFC` (lembrando sempre de adicionar o +4 do PC+4) chegamos em `0x2001 F000`, endereço superior ao `0x2001 4924` do exercício 39, portanto conseguimos chegar sim.

### 2.43

Write the MIPS assembly code to implement the following C code: 

```c
    lock(lk); 
    shvar=max(shvar,x); 
    unlock(lk);
```

Assume that the address of the `lk` variable is in `$a0`, the address of the `shvar` variable is in `$a1`, and the value of variable `x` is in `$a2`. Your critical section should not contain any function calls. Use ll/sc instructions to implement the lock() operation, and the unlock() operation is simply an ordinary store instruction.

```assembly
.text
.globl main

main: 
    jal lock            # executa a procedure lock
    slt $t0, $a1, $a2   # se a1 > a2 então $t0 = 0
    beq $t0, $zero, L1  # se t0 = 0 então pula para L1
    add $a1, $a2, $zero # se t0 = 1 então shvar = x
L1: jal unlock          # executa a procedure unlock

lock: 
try:
    ll $t1, 0($a0)      # t1 = MEM[$a0], inicia operação atômica
    bne $t1, $zero, try # se t1 != 0, o semaforo está fechado, então volta para try
    addi $t1, $zero, 1  # se t1 = 0, t1 += 1
    sc $t1, 0($a0)      # MEM[$0] = t1, tenta concluir operação atômica
    beq $t1, $zero, try # se t1 = 0, a operação atômica falhou e deve voltar ao início
    jr $ra              # retorna para caller

unlock:
    sw $zero, 0($a0)    # MEM[$a0] = 0
    jr $ra              # retorna para caller
```