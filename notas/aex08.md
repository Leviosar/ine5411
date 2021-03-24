# Suporte para aritmética inteira e sincronização de threads

# Overflow

É comum durante a execução de um programa que sejam realizadas operações que podem resultar em erros como o *overflow*, nesse caso a ISA do processador precisa estar preparada para lidar e sinalizar esses erros. Mas antes de tudo, uma breve revisãozinha sobre inteiros sinalizados e o conceito de overflow.

## Complemento de 2

A maneira mais comum de ser utilizada para representar numeros com sinal de forma binária é o complemento de 2, também é a maneira que os processadores modernos trabalham. A fórmula geral de um número binário com sinal representado em complemento é: 

```
- 2ⁿ⁻¹ × bitₙ₋₁ + 2ⁿ⁻² × bitₙ₋₂ + … + 2² × bit₂ + 2¹ × bit₁ + 2⁰ × bit₀
```

Prestando atenção da pra ver que o sinal do número na verdade será definido pelo bit mais significativo, caso ele seja 0 todo o termo com - na frente será zerado e o número a partir dai só tem como ser positivo, caso seja 1 o termo vai gerar um número negativo MAIOR do que a soma de todos os outros termos, por isso temos um número negativo como final. A faixa de números representaveis por um complemento de 2 de N bits é `[- 2ⁿ⁻¹, + 2ⁿ⁻¹ )`.

O MIPS utiliza complemento de 2 com um total de 32 bits por número, portanto podemos representar qualquer número entre `- 2³¹` e `+ 2³¹ - 1` pois temos um número positivo a menos para representar (na verdade, o zero é representado como positivo e "rouba" esse espaço).

## Ocorrência de overflow

O overflow no complemento de 2 pode acontecer apenas nos casos em que:

1. Temos uma soma de dois números com o mesmo sinal
2. Temos uma subtração de dois números com sinais diferentes
3. Temos uma multiplicação de dois números 

## Tratamento de overflow no MIPS

O MIPS possui um mecanismo de detecção de overflow na própria ULA, então sempre após uma operação a ULA irá sinalizar se ocorreu ou não o overflow. Depois disso, caso ocorra o overflow, o hardware do controle irá desviar para uma rotina do sistema operacional responsável por tratar exceções (essa rotina no MIPS sempre está no endereço `0x8000 0180`). Ao final da execução dessa rotina, ela irá executar algo parecido com o seguinte bloco:

```
mfc0 $k0, $14 # $k0 = EPC
jr $k0 # PC = $k0
```

O que ele faz é acessar o registrador EPC (*Exception Program Counter*) que contém o endereço da instrução que causou a exceção, ele acessa isso com a instrução `mfc0` (*move from system control*) que pode acessar registradores do banco secundário do MIPS. Depois disso ele pula para a instrução que causou o problema.

# Suporte para programas paralelos

## Sincronização

