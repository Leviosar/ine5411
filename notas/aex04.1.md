# Operações lógicas

Diferentemente das operações aritméticas, as operações lógicas tratam os seus operandos bit-a-bit e não como um número inteiro. No geral, podemos dizer que temos as seguintes operações:

## Deslocamentos 

Podemos deslocar um número a esquerda ou a direita, sendo que as instruções disponíveis são respectivamente `sll` e `slr`. Elas tem o formato de instruções do tipo R, entretanto o seu segundo operando é uma constante, portanto a instrução utiliza apenas 2 campos de registradores.

Um exemplo de sintaxe, deslocando um número dois bits a esquerda e colocando no próprio registrador fonte é: 

```assembly
sll $s0, $s0, 2
```

Lembre-se que, para o caso de números sem sinal, deslocar um número `n` bits para a esquerda é o mesmo que multiplicar esse número por `2ⁿ`. Ou seja, no exemplo anterior nós multiplicamos o valor de `$s0` por 4. De forma semelhante, deslocar a direita `n` bits é uma divisão inteira por `2ⁿ`.

## and

A operação `and` já é conhecida por todo mundo, mas talvez tenham algumas coisinhas que você não sabe ainda. Primeiramente, como na ISA do MIPS essa operação é um bitwise-and, é possível utilizar ela para aplicar máscaras que forcem uma porção da palavra a ser 0. Por exemplo, caso eu aplique `1111 1111 1111 1111 0000 0000 0000 0000` em qualquer número utilizando um and, os 16 bits menos significantes do resultado serão obrigatóriamente 0, enquanto os 16 bits mais significativos serão os bits do número original.

## or

Bom, é só uma operação or bit-a-bit, não tem muito o que falar aqui.

## nor

A operação `nor` é uma negação do `or` e a única forma de negação implementada pela ISA do MIPS. "Mas e se eu quiser fazer um not?". Bom, é ai que entra a álgebra booleana, podemos criar um `not` a partir de um `nor` caso um dos operadores seja composto apenas de zeros. No MIPS, temos o registrado `$zero` que pode servir perfeitamente a esse propósito

# Suporte a decisões

É absurdamente comum programas de computador possuírem tomadas de decisão, é basicamente isso que diferencia computadores de calculadoras. Sendo assim, o MIPS precisa providenciar alguma forma para realizarmos essas tomadas de decisão. Isso tudo é suportado pelos desvios na ISA do MIPS, sendo que eles podem ser classificados entre desvios condicionais e desvios incondicionais.

## Desvio condicional

O desvio condicional apenas é tomado quando uma determinada condição é cumprida, como usamos em linguagens de programação de alto nível ao dizer `if exp then a else b`. O MIPS suporta diversas instruções desse tipo, mas as duas principais são `beq` (branch on equal) e `bne` (branch on not equal).

A sintaxe base para os dois casos é:

```assembly
beq $s0, $s1, address
```

Sendo que `address` é uma label que ao final do processo de compilação representará um endereço de memória; 

## Desvio incondicional

Esses desvios são ainda mais simples de serem entendidos, eles acontecem SEMPRE que a instrução for chamada, não existe condição. O MIPS implementa alguns tipos de *jumps* (outra forma de chamarmos essas instruções), mas o mais comum é a instrução `j`.

A sintaxe é ainda mais simples:

```
j address
```

Sendo que `address` é uma label que ao final do processo de compilação representará um endereço de memória; 

## Uso prático de desvios

### Compilando um if-else

Podemos pensar que os *jumps* não são tão utilizados assim em programas, mas isso está errado. Instruções jump são utilizadas em todos os blocos básicos de tomada de decisão que usamos diariamente, vou dar agora um exemplo utilizando um código C para um `if-else`. 

Registradores: 

```
(f, g, h, i, j) == ($s0, $s1, $s2, $s3, $s4)
```

Código C:

```c
if (i == j) {
    f = g + h;
} else {
    f = g - h
}
```

Representação possível em assembly:

```assembly
Main:
  bne $s3, $s4, Else
  add $s0, $s1, $s2
  j Exit
Else:
  sub $s0, $s1, $s2
Exit:
  ...
```

Como eu preciso executar apenas uma das ramificações, significa que ao terminar de executar ela eu preciso ir DIRETAMENTE para o label Exit, sendo necesssário adicionar um `j Exit` ao final do primeiro ramo para isso. Não precisamos adicionar um `j Exit` ao final do ramo `Else` pois a próxima instrução após ele já é a label Exit.

### Compilando um while

Para fixar melhor, vamos agora compilar uma estrutura de repetição, mais especificamente um `while`.

Registradores: 

```
(i, k) = ($s3, $s5); 
$s6: base do arranjo “save”
```

Código C:

```c
while(save[i] == k) {
    i += 1;
}
```

Representação possível assembly:

```
Loop:
  sll $t1, $s3, 2    # multiplica o valor de i por 4 (número de bytes na palavra)
  add $t1, $t1, $s6  # com o valor de i já multiplicado por 4, somamos a base de $s6 para obter save[i]
  lw $t0, 0($t1)     # carrega o valor de save[i] em $t0
  bne $t0, $s5, Exit # caso save[i] != k, vai para o label exit
  addi $s3, $s3, 1   # caso o contrário faz i += i
  j Loop             # retorna para o começo do loop
Exit:
  ...
```

## Blocos básicos

Uma sequência de instruções onde não temos desvios (exceto no final) e nem labels (exceto no início) pode ser chamada de bloco básico. Usamos blocos básicos para a geração de código no processo de compilação. Além de servir como modelo de otimização para paralelismo, já que quando não temos dependência de dados dentro do bloco, podemos "embaralhar" as instruções e executar elas em ordem diferente para tirar o máximo do nosso *pipeline*.

> Nota do escritor: eu sei que você não sabe pipelines ainda, o único motivo para eu saber isso é porque gostei tanto da disciplina que acabei fazendo ela mais de uma vez. O professor as vezes (sempre) se atropela no conteúdo e acaba citando coisas que você ainda não aprendeu, se acostume a ignorar isso eventualmente. 

# Operações de comparação

Além de comparar igualdade e desigualdade precisamos ser capazes de realizar outros tipos de comparação, sendo a mais utilizada a comparação "menor que". Essa comparação é implementada no MIPS pela instrução `slt` (set on less than) que seta um bit do registrador destino como 1 caso o primeiro argumento seja menor do que o segundo, caso o contrário seta como 0. Também existe uma versão imediata do `slt` chamada `slti` que trabalha com constantes.

A sintaxe é: 

```
slt $t0, $s3, $s4 # $t0 = 1 se $s3 < $s4
```

Você pode se perguntar, "Mas e a comparação maior que?". Simples, inverta a ordem dos operandos.

E é isso, o MIPS utiliza apenas essas instruções para implementar comparações.

### Bonus round: pseudoinstrução blt

É possível implementarmos uma pseudoinstrução `blt` (branch on less than) utilizando duas instruções nativas para isso. Primeiro, uma instrução `slt` e depois um `bne`.

```assembly
slt $t0, $s0, $s1       # $t0 = 1, se $s0 < $s1
bne $t0, $zero, Less    # vá para “Less”, se $t0 0 ($s0 < $s1)
```

### Bonus round 2: tabela de alcances

Fazendo um resumo de todos os modos possíveis de criar um desvios, partindo do menor alcance para o maior, temos:

1. Branches (beq, bne):

**Alcance**: [-2^17, +2^15] relativo a PC+4, ± `0x1 FFFC`

2. Jump (j):

**Alcance**: Os 26 bits do campo const, deslocados a esquerda, `26bits << 2` Substitui os 28 LSBs de PC

3. Jump register (jr):

**Alcance**: Toda a memória capaz de ser indexada por um registrador, visto que ele faz PC = $registrador