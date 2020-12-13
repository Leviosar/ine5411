# Memória virtual

O conceito de memória virtual é introduzido como uma forma de evitar acessos a disco, funcionamento de forma semelhante a uma cache (percebe que aqui não estamos falando de uma cache de disco propriamente dita, essas caches de disco existem mas normalmente estão localizadas no próprio disco).

É comum que no uso cotidiano de um computador se queira executar diversos programas simultaneamente, e normalmente esses programas estão localizados no disco, porém ao iniciar a execução, trazemos eles para a memória principal para diminuir o tempo desprendido em acessos a disco. Como a memória principal é limitada, precisamos gerenciar os programas de forma a minimizar a quantidade de programas ativos em disco. Como nem todas as porções de um programa estão ativas o tempo todo, podemos carregar apenas as porções ativas em memória e manter as inativas em disco (até que sejam inativadas).

Além disso, é necessário garantir a segurança dos programas, impedindo acessos de um programa X para a região de memória do programa Y.

## Propriedades do gerenciamento de memória virtual

Supondo um sistema que aplique os conceitos de memória virtual, temos algumas consequências diretas disso que são interessantes de serem estudadas.

### Extensão do espaço de endereçamento

Suponha um sistema de 32 bits, com memória principal de 1GB. Sabemos que com 32 bits se pode endereçar 4GB de memória, então estamos "perdendo" 3GB de endereçamento ao usar apenas o espaço disponível na memória principal. Com o gerenciamento de memória virtual, estamos limitados ao endereçamento do processador, podendo endereçar qualquer coisa no espaço de 2^32, realizando transferências entre memória principal e HD quando necessário (afinal de contas a memória principal continua tendo 1GB).

### Relocação de programas e dados

### Compartilhamento de memória

Utilizando-se do conceito de memória virtual, podemos ter áreas de memória compartilhadas entre programas diferentes, permitindo uma comunicação mais simples entre esses processos. Todavia, é necessário que proteções sejam implementadas nessas áreas compartilhadas, essas proteções costumam ser providas pelo SO e não pelo hardware.

## Proteção de memória

Em decorrência do compartilhamento de memória mencionado anteriormente, temos que criar as proteções necessárias para garantir a corretude do sistema, existem duas soluções principais, mas o professor decidiu que não queria dar aula sobre a primeira então por enquanto só vou falar da segunda (talvez eu volte atrás nisso depois).

### Solução 2: espaços de endereçamento separados

Nessa solução, cada programa é compilado como se ele fosse dono da memória completa, contendo seu próprio __espaço virtual de endereçamento__, porém obviamente não podemos ter 2 programas em execução que pensam ser "donos" da memória completa.

## Tradução de endereços

Quando um programa utiliza uma instrução contendo um endereço, esse endereço será um `virtual address`, que precisa ser traduzido para um `physical address`. Digamos que um programa executou `lw $t0, 1024($r0)`. O tradutor (futuramente chamaremos de _page table_) vai ver esse endereço e dizer que o `endereço físico` correspondente a 1024 é o endereço 2 (só uma suposição). Então, vamos buscar dentro da RAM o `endereço físico` 2.

É possível que nossos dados não estejam em RAM, nesse caso o tradutor simplesmente vai dizer que o dado se encontra no disco, sabendo disso pegaremos o dado em disco e carregaremos em RAM em um `endereço físico` vazio. Após fazer isso precisamos também atualizar o nosso tradutor, para que ele saiba que o endereço do dado recém carregado.

## Tabela de páginas ou page tables

Até agora estávamos falando do "tradutor" como uma entidade mística que magicamente sabe onde estão nossas coisas, mas chegou a hora de dar nome aos bois. O tradutor é chamado de tabela de páginas, ele é responsável por conter entradas que mapeiam um endereço virtual para um endereço físico, com cardinalidade 1. 

Mas, pensando assim, precisariamos ter uma entrada para cada palavra disponível nos processador, o que em um MIPS 32 totaliza 2^30 entradas, 1GB de memória sendo gasta para fazer a tabela de páginas. Além disso, cada programa tem sua própria tabela, então isso definitivamente é um problema, não podemos gastar 1GB apenas pra fazer o mapeamento de endereços de cada programa.

Como a gente resolve isso? Certamente não podemos excluir a tabela de páginas do processo, isso faria com que não tivessemos um meio de conseguir traduzir endereços virtuais em endereços físicos. O que podemos fazer é agrupar as palavras em grupos maiores, que vamos chamar de páginas (é dai que vem o nome do tradutor inclusive), cada página tendo um número considerável de bits, para que valha a pena e reduza o custo de construção da tabela.

Vamos dar um exemplo, de uma tabela que mapeia 4kB, ela pode mapear por exemplo os endereços virtuais de 0 a 4095 para 4096 a 8191. Quanto maior o range que uma página única consegue mapear, menor a quantidade de páginas no sistema e menos recurso utilizado para construir a tabela. Mas tudo vem com um preço, ao agrupar as palavras perdemos flexibilidade, pois estaremos tratando as páginas como pedaços contíguos de memória, caso eu queira mover o endereço 12 no exemplo anterior, precisarei mover a primeira página completa, dos endereços 0 até 4095.

Ainda no exemplo anterior, caso eu queira saber onde na memória física está o endereço virtual 4, verei na tabela que a página dele (0, 4095) está mapeada para (4096, 8191), a partir dai, eu sei que o meu endereço possui um _offset_ total de 4, aplicando isso para o endereço físico eu obtenho o endereço 4100.

### A estrutura da tradução de endereços utilizando uma tabela de páginas

Vamos criar um exemplo de um sistema com endereçamento de 32 bits, 256 MB de memória RAM e páginas com tamanho de 4kB.

- 256MB de RAM resultam em um endereço físico de até 2^28, ou seja, 28 bits para o endereço físico

- O endereço virtual vai acompanhar o endereçamento do sistema e ter 32 bits

- Como a página possui 4096 endereços, precisamos de um offset capaz de navegar por eles, resultando em 12 bits (2^12 = 4096). Esse offset é igual para PA e VA.

- Isso significa que no VA sobram 20 bits para serem traduzidos em 16 bits do PA. Os 20 bits do VA serão chamados de _virtual page number_ e os 16 bits do PA serão chamados de _physical page number_.

## Page faults

Quando um acesso na tabela de páginas disser que o dado não está em RAM e sim em disco, temos um _page fault_, o hardware vai gerar uma _page fault exception_, que será pega pelo SO e tratada pelo _page fault handler_ (PFH).

O PFH então vai escolher uma das páginas que está em RAM e trocar pela página requisitada que está em disco, caso a página escolhida para ser expulsa da RAM esteja _dirty_ (ou seja, foi alterada pelo programa de alguma forma), ela deve ser escrita em disco antes de ser expulsa. Depois disso, o PFH pega a página requisitada em disco, escreve na RAM, altera a tabela de páginas para refletir o novo local da página requisitada e por fim, retorna para a instrução que causou a _page fault exception_.

## TLB

Mesmo tudo isso funcionando bonitinho, ainda assim estamos realizando muitos acessos em memória pra cada vez que temos que olhar na tabela de páginas, isso acabaria sendo muito custoso e eliminando os benefícios obtidos pelo uso de memória virtual. Talvez então seja a hora de criar uma cache para a nossa tabela de páginas.

Vamos chamar essa cache de Translation Lookaside Table, ela vai atuar entre o processador e a memória onde a tabela de páginas está guardada. Ela usa o _virtual page number_ como _tag_ e guarda o _physical page number_ como dados.

# Glossário

- `Virtual memory`: memória que o seu programa vê, o que ele acha que está acessando quando pede ao processador para acessar.

- `Virtual address` (VA): endereço utilizado pelo seu programa, na prática o range dele é o range de endereçamento do seu processador, caso seja um processador de 32 bits teremos 2^32 - 1 endereços disponíveis.

- `Physical memory`: memória física instalada no sistema, o que os seus programas eventualmente irão acessar.

- `Physical address` (VA): endereço real contido na RAM, o range dele é definido pela quantidade de RAM que você tem instalada, então se por exemplo tiver 2GB de RAM, você vai ter 2^31 - 1 endereços