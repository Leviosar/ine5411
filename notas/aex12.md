# AEX12 - Montador

- Labels globais e locais são processados pelo montador.
- O montador roda duas vezes, na primeira coletando as definições de cada label, e na segunda aplicando essas definições em cada uso.
- Labels externos são processados pelo ligador.
- O montador trabalha em um único arquivo, o ligador trabalha em vários arquivos.

### Montador - princípio de funcionamento

O montador funciona em dois passos diferentes.

1. No passo 1, ele executa a extração de componentes e campos das instruções, além de mapear referências (como as labels) para endereços de memória.

2. No passo 2, ele efetivamente faz a tradução das instruções de assembly para código binário.

Ao final da execução do montador, o código ainda não está pronto pra ser executado pois o montador não consegue resolver referências externas, como chamadas para bibliotecas. Antes do código ser executado, o ligador irá resolver essas referências.

### Macros vs Pseudoinstruções

Um montador pode possuir o recurso de processamento de macros, onde você pode criar por exemplo um macro `print_int($arg)` que chama o seguinte código:

```assembly
la $a0, str
mov $a1, $arg
jal printf
```

O montador ao processar esse macro, irá procurar por todas as chamadas pelo código, digamos que você tenha o seguinte trecho

```assembly
print_int($7)
print_int($s0)
print_int($a0)
```

O montador então irá COPIAR e COLAR o trecho da macro, substituindo os argumentos pra cada vez que eles aparecem, no caso acima então o montador produziria 9 linhas de instrução (3 pra cada chamada). Mas isso tem um problema, no último caso passamos o valor de $a0 para a macro, mas esse valor é alterado dentro da própria macro na instrução `la $a0, str`. Então teriamos nossa chamada invalidada pois o valor original é destruido.

Como resolver isso? **Pseudoinstruções**.

O montador também está equipado com um conjunto de pseudoinstruções, criadas para abstrair uma ou mais instruções para uma única instrução mais clara. Um bom exemplo é a pseudoinstrução `mov $t1, $t0` internamente implementada como `add $t1, $t0, $zero`. Perceba que o efeito de somar um valor com 0 e coloca-lo num lugar X é o mesmo de simplesmente mover o valor para X.

No MIPS, para evitar conflito de registradores, as pseudoinstruções possuem um registrador próprio chamado $at.

### Layout de memória

![Layout de memória do MIPS implementado no simulador MARS](https://imgur.com/bAwm2kx.png)

No modelo acima, podemos ver por exemplo que a parte reservada para o código da aplicação (text) possui 252 MB (seriam 256 caso não houvessem 4 MB reservados). Logo acima temos uma área bem pequena reservada para dados estáticos e por última temos a área de dados dinâmicos, ocupada simultâneamente pela stack e pela heap que crescem em direções concorrentes para poderem usar melhor o tamanho total da área reservada. 

Perceba que na imagem tudo isso corresponde a 2GB, mas sabemos que o MIPS 32 pode endereçar até 4GB de memória, então para o que está sendo usado o resto? São 2 GBs reservados para o funcionamento do SO.

- Pilha: guarda variáveis que não puderam por algum motivo serem alocadas em registradores ou que precisaram ser salvas em chamadas de procedimentos.
- Heap: guarda estruturas de dados, principalmente as que trabalham com ponteiros como listas encadeadas e semelhantes.
- Static: guarda variáveis alocadas de forma estática, que vão permanecer alocadas durante todo o programa. Em C podemos alocar uma variável estática utilizando a keyword `static`.

### Formato do arquivo objeto

- Object file header: tamanho e posição das outras seções

- Text segment: código em linguagem de máquina

- Static data segment: segmento de dados estáticos (que vão parar naquele espaço de 64k)

- Relocation information: instruções e dados que dependem de endereços absolutos

- Symbol table: lista de referências a chamadas externas.

- Debugging information: informações da compilação.