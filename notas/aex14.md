# Carregador

É um programa que faz parte do sistema operacional, responsável por pegar o arquivo executável gerado pelo ligador e colocar pra rodar.

Em resumo, o SO segue esses passos:

1. Lê o arquivo executável no disco
2. Carrega ele em memória
3. Dispara a execução

Já o carregador, tem como principais passos do processo:

1. Lê o header do arquivo exeutável
    - Pra determinar segmentos de dados e texto
2. Cria um espaço de endereçamento pros dois segmnetos
3. Copia o segmento de texto e os dados pro espaço alocado previamente
4. Copia os parâmetros do programa para a pilha
5. Inicializa registradores
    - De uso geral e stack pointer
6. Inicia e termina a execução
    - Desvia pra rotina de inicialização
    - Chama rotina principal
    - No retorno, termina o programa com uma chamada de sistema (`syscall exit`)

# DLL: a noção de ligação dinâmica

Até agora, estudamos a ligação estática, que acontece antes do programa entrar em execução. Esse tipo de ligação tem algumas desvantagens:

1. Não permite "upgrade" de bibliotecas
    - Rotinas estão incorporadas no executável
    - Programa continua usando versão antiga da biblioteca, mesmo com uma nova disponível
    - Teria que recompilar (religar) o código para atualizar
2. Todas as rotinas invocáveis são carregadas em memória
    - Presuma o caso onde uma rotina é chamada num `else`, mas esse ramo `else` só é executado em 1% das execuções do programa. Você carregou essa rotina pra ser executada uma vez a cada 100.
    - Ocupação ineficiente da memória
3. Redundância no sistema de arquivos
    - Posso ter o meu programa guardado várias vezes em disco.
4. Redundância em memória
    - Posso ter a mesma rotina carregada em vários pontos de memória por programas diferentes, sendo que poderia ter apenas uma vez.

Mas também tem algumas vantagens:

1. É o meio mais rápido de se acessar uma rotina, pois ela é "embutida" no arquivo executável

Como deu pra ver, as desvantagens se sobressaem, por isso existe uma outra maneira de linkar código, uma ligação dinâmica. De onde vem o termo DLL ("Dynamic Linked Libraries").

Dessa forma, a rotina não é ligada no processo inicial de ligação, ficando como uma referência inacaba, mas em tempo de carregamento (ou de execução) essa rotina será carregada dinamicamente.Existe obviamente um trade-off, o arquivo executável que utiliza ligação dinâmica precisa ter instruções para a ligação das bibliotecas faltantes.

### Ligação dinâmica em tempo de carga

Nesse caso, o carregador irá invocar o ligador durante o processo de carregamento para resolver as referências faltantes, isso elimina o problema da falta de upgrade nas bibliotecas, mas ainda nos deixa com o problema de carregar todas as rotinas invocáveis, já que não sabemos quais rotinas vão ser chamadas em tempo de execução.

### Ligação dinâmica em tempo de execução

Nesse caso, a rotina é ligada o mais tarde possível: exatamente na hora em que ela for chamada. O nome disso é "lazy procedure linkage", dessa forma apenas as rotinas invocadas serão carregadas em memória.

O desempenho desse método é próximo ao obtido com ligação estática, mas na primeira invocação de cada rotina ela terá que ser carregada e isso irá degradar meu desempenho. Por exemplo, uma rotina utilizada 999999 vezes, só será carregada pra memória na primeira vez, então é muito vantajoso utilizar DLL nesse caso.