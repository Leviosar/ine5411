# ISA: Suporte para inteiros compactos, textos e constantes de 32 bits.

Até agora trabalhamos apenas utilizando números inteiros de 32 bits, mas nem tudo na computação é Int32 não, processadores precisam ter suporte para outros tipos numéricos e até tipos não numéricos, nessa seção vamos dar uma olhada em como a ISA do MIPS 32 suporta outros tipos de dados.

Normalmente essa aula começaria com uma revisão sobre complemento de dois e extensão de sinal, mas vou acabar deixando isso como um bônus no final, caso eu já tenha escrito esse bônus, acesse clicando [aqui](./aex06.md).

## Instruções de suporte para inteiros compactos

Para inteiros com menos de 32 bits, o ponto principal a ser cuidar é o "resto do número", afinal pela filosofia RISC vamos manter os dados todos alinhados em memória, portanto se um número ocupa 16 bits os outros 16 bits da palavra devem ser preenchidos de alguma forma, sem alterar a interpretação do número original. Para isso, o MIPS dispõe de instruções utilizadas para números com e sem sinal.

### Sinalizados

Para números com sinal, o MIPS deve utilizar a extensão de sinal para complementar o número como um complemento de 2. Na prática, a instrução carrega o número nos N bits menos significantes, onde N é o tamanho do número carregado, após isso os bits restantes são preenchidos pelo extensor de sinal.

As instruções que suportam isso são `lb` (load byte) e `lh` (load half) que carregam respectivamente números de 8 e 16 bits.

### Não sinalizados

No caso de números não sinalizados é um pouco mais simples, só precisamos carregar o número nos N bits menos significantes e completar o resto com zeros. Também são duas instruções que implementam esse suporte, de forma semelhante mas apenas com o sufixo `u`: `lbu` (load byte unsigned) e `lhu` (load half unsigned).

## Instruções de suporte para char e string

Históricamente, computadores não foram feitos para suportar texto, eles eram construídos unicamente para computar operações matemáticas. Obviamente, nossa realidade atual é outra e todo processador que se preze deve suportar texto de alguma forma, a mais rudimentar dela é utilizando a tabela ASCII, onde cada caractere utiliza 8 bits para ser representado. Representações mais modernas como o Unicode requerem mais bits.

Quando escolhemos trabalhar com ASCII por exemplo, o processador busca o caractere na memória utilizando `lbu` já que não existem negativos no ASCII, e salva utilizando `sb` (store byte). Ao utilizar Unicode, representado em 16 bits, as instruções `lhu` e `sh` (store half) provém suporte para as operações.

Mas isso aqui descreve o funcionamento para um único caractere, o que normalmente não é o caso de uso comum, já que trabalhamos muito com strings. Como representamos uma string em memória? Bom, existem 3 soluções principais.

1. A primeira posição da string armazena seu comprimento.
2. Alguma variável qualquer armazena o comprimento da string.
3. A última posição é marcada com um caractere especial de fim de string (\0 na linguagem C).

### Exemplo: rotina em C para copiar string

Para a alocação utilize:

– $a0 e $a1: endereços-base dos arranjos x e y
– $s0: variável i

```c
void strcpy (char x[ ], char y[ ])
{ 
    /* copia string y para string x */
    int i;
    i = 0;
    while ( (x[i] = y[i]) !=‘\0’ ) /* copia e testa byte */
    i += 1;
}
```

```assembly
    addi $sp, $sp, -4
    sw $s0, 0($sp)

    move $s0, $zero

L1:
    add $t1, $s0, $a1
    lbu $t2, 0($t1)
    add $t3, $s0, $a0
    sb $t2, 0($t3)

    beq $t0, $zer0, L2

    addi $s0, $so, 1
    j L1

L2:
    lw $s0, 0($sp)
    addi $sp, $sp, 4
    jr $ra
```

## Constantes de 32 bits

Vamos voltar um pouco agora, pra aula onde aprendemos sobre os diferentes formatos de instrução. Vimos que existem os formatos R, I e J. Também foi introduzido o conceito de desvios condicionais e incondicionais, sendo que os desvios condicionais pertencem ao formato I, enquanto os incondicionais ao formato J. Se lembrarmos da estrutura desses dois formatos temos:

- Formato I

| opcode | rs     | rt     | const   |
| ------ | ------ | ------ | ------- |
| 6 bits | 5 bits | 5 bits | 16 bits |

- Formato J

| opcode | const   |
| ------ | ------- |
| 6 bits | 26 bits |

Perceba que a constante de desvio que está representada no campo `const` possui tamanhos diferentes nesses tipos, tendo 16 bits nos desvios condicionais e 26 nos desvios condicionais. Aqui surge o nosso problema: com um desvio condicional desse tamanho, um programa pode ter no máximo 64k de tamanho, afinal precisamos garantir que seja possível a qualquer ponto do programa utilizando um desvio. Idealmente, gostariamos de poder fazer desvios maiores que esses, então os projetistas tiveram que achar uma solução.

### Endereçamento relativo

A solução implementada foi de realizar apenas desvios condicionais **relativos**, onde o desvio é realizado com base num cálculo feito com o _program counter_, ou seja, ao invés de pularmos para o endereço `const` vamos pular para o endereço `PC + const`. Assim, temos como range de deslocamento `(-2¹⁵, +2¹⁵]

> É importante lembrar que a primeira coisa que acontece ao buscar uma instrução é incrementar PC em 4, então o endereço calculado pelo desvio na verdade é PC + const + 4.

Calma que aqui ainda tem uma pegadinha, no MIPS temos endereços sempre múltiplos de 4, e existe uma propriedade dos números binários múltiplos de 4 que diz que todos eles terminam e "00". Sendo assim, podemos excluir esses dois últimos dígitos da codificação, para ganhar espaço. Dando um exemplo, caso a gente queira pular 8 (1000) bytes (saltando duas instruções) vamos dizer ao MIPS que queremos pular 2 (10) palavras, perceba que se adicionarmos 00 ao número 2 chegaremos em 8.

### Desvio condicional insuficiente

Caso você escreva um código que acabe gerando um desvio condicional que não pode ser codificado por estar muito longe em memória, o ligador irá inverter seu desvio condicional e adicionar um desvio incondicional logo abaixo de forma a permitir que sejam usados os limites de desvios incondicionais.

#### Ranges de desvio

| Método                                        | Tamanho do campo | Alcance real |
| --------------------------------------------- | ---------------- | ------------ |
| Desvio condicional relativo                   | 16 bits          | 18 bits      |
| Desvio incondicional                          | 26 bits          | 28 bits      |
| Desvio condicional tratado como incondicional | 26 bits          | 28 bits      |
| Jump register                                 | 32 bits          | 32 bits      |