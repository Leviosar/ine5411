# Tratamento de exceções

## Interrupção vs Exceção

O livro texto classifica as exceções em duas categorias principais

1. Exceção: ocorre dentro da CPU
    - Overflow
    - Divisão por zero
    - Instrução indefinida
    - Chamada de sistema

2. Interrupção: ocorre fora da CPU
    - Requisição para I/O
    - Disfunção no HW

## Suporte no hardware

Ainda assim, o hardware também precisa oferecer suporte para o tratamento de excessão, no caso do MIPS existe primeiramente um mecanismo para detecção dessas exceções, que atua na ULA (nos casos de overflow e divisão por zero) ou no controle (nos casos de instrução indefinida).

Ao detectar a exceção, o processador irá sinalizar a linha do programa onde ela ocorreu, para que essa linha possa ser restaurada caso o SO trate a exceção. Esse dado fica salvo num registrador adicional chamado EPC (Exception Program Counter).

Apensar sinalizar o acontecimento de uma exceção não é o suficiente, o hardware também precisa indicar qual foi a causa da exceção, essa causa é então codificada e salva num registrador adicional chamado _cause_.

### A anatomia do registrador _cause_

- Exception code: bits 2 a 6
- Pending interrupts: bits 8 a 15
- Branch delay: bit 31

![Tabela de códigos de excessão](https://imgur.com/4rzDqWz.png)

Para dar suporte a múltiplas exceções simultâneas, o MIPS utiliza um outro registrador chamado **status**.

### A anatomia do registrado _status_

- Interrupt enable: bit 0 (0 disabled, 1 enabled)
- Exception level: bit 1 (0 no exception, 1 exception)
- User mode: bit 4 (0 user, 1 kernel)

Para eventos ainda mais específicos, como uma exceção gerada no subsistema de memória (por exemplo um acesso indevido ou então um endereço desalinhado), nesse caso o MIPS utiliza outro registrador chamado BadVAddr (Bad Virtual Address). Ainda existem outros vários registradores específicos para tratar outros tipos de exceções menos comuns.

## Exception handler

O próprio SO é responsável por lidar primariamente com a exceção, decidindo se irá tratar ela ou abortar a execução do programa. Quem faz esse tratamento é um peça do SO chamada de _exception handler_.

Esse _exception handler_ é um programa como qualquer outro e possui um fluxo de execução que funciona da seguinte forma:

1. Salvamento de contexto
    - Registradores usados pelo tratador precisam ser salvos por ele mesmo para uma restauração futura
2. Decodificação da causa
    - Vai buscar e interpretar o valor do registrador _cause_.
3. Ação corretiva ou sinalizadora
    - Chama uma rotina que irá tratar daquela tipo específico de exceção.
4. Restauração de contexto
    - Os valores salvos na pilha durante o passo 1 são restaurados aos seus registradores
5. Retorno
    - Volta a executar a partir de EPC ou EPC+4

O código desse programa tratador de exceções faz parte da área alocada para o SO, então está nos 2 GB superiores da área de memória, no caso do MIPS o endereço padrão é `0x80000180`. Dessa forma, quando o hardware detecta uma exceção, pode carregar o valor `0x80000180` no PC.

# MIPS: Decomposição da ISA

Até agora tinhamos visto o MIPS apenas com seu conjunto inteiro de 32 registradores de 32 bits e sua CPU principal, mas acontece que existem outras partes do MIPS que realizam outras funções. Como é o caso da FPU (Floating Point Unit) e do suporte a exceções que acabamos de ver.

Na FPU temos 32 registradores de 32 bits que podem ser configurados para 16 registradores de 64 bits, além de uma AU (uma ALU sem lógica) que faz operações básicas de ponto flutuante.

Na unidade de suporte a exceções, é interessante falarmos das instruções `mfc0` e `mtc0`, expandidas para `move from coprocessor 0` e `move to coprocessor 0` respectivamente. São elas que usamos para resgatar e enviar valores para os registradores do processador de suporte a exceções. 