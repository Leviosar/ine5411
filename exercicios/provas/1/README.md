# Prova 3

## Questão 1

Um processador permite endereçar 2³² bytes. Um programa compilado para esse processador requer um espaço de endereçamento de 2³⁰ bytes. Sabe-se que o sistema de gerência de memória virtual aloca páginas somente na faixa de endereços correspondente aos primeiros 2147483648 bytes da memória física (o resto da memória é usado para outros propósitos como, por exemplo, manter a tabela de páginas). Sabe-se que o tamanho de página adotado é de 16384 bytes. Suponha que se use o mínimo número de bytes para acomodar uma entrada da tabela de páginas (não se esqueça que esse número precisa ser inteiro). Sabe-se que são necessários 3 bits para codificar o estado de uma página.

Nestas condições, quantos bytes são necessários para armazenar a tabela de páginas desse programa?

### Resolução

Primeiro, entendemos que vamos fazer uma tradução de um endereço virtual de 30 bits para um endereço físico de 32 bits.

Depois podemos obter o _page offset_ a partir do tamanho da página, fazendo log₂(_page size_) ou log₂(16384) e vamos descobrir que precisamos de 14 bits para _page offset_.

Tendo o tamanho de 30 bits para o endereço virtual e 14 bits para o _page offset_ sobram 16 bits para o _physical page number_, entretanto como o endereço final é de 32 bits, precisamos adicionar mais 2 bits a essa conta, totalizando 18 bits para o _physical page number_. Além disso, o problema nos diz que temos 3 bits de estado para cada entrada da tabela, então chegamos a um total de 21 bits por entrada. Como o valor pedido é em bytes, podemos fazer 21 bits caber em um espaço de 3 bytes.

Como o _virtual page number_ é representado com 16 bits da pra supor que eu temos 2¹⁶ páginas

`2¹⁶ entrada/tabela * 3 bytes/entrada` = **196608 bytes/tabela**

## Questão 3

Um processador usa endereços de 32 bits e uma pequena cache de mapeamento direto. A Tabela abaixo mostra uma sequência de referências à memória em ordem temporal (de cima para baixo). Cada linha da tabela representa os 16 bits menos significativos de um endereço referenciado, sendo que os 16 bits mais significativos são todos zeros. Sabe-se que a cache tem capacidade para armazenar apenas 4 blocos de memória e que cada bloco ocupa 8 bytes.

![Tabela de endereços](https://imgur.com/TLCPR39.png)

Nestas condições, responda:

O número de acessos à memória que resultam em acertos em cache é: [2]

O número de acessos à memória que resultam em substituição de bloco em cache é: [7]

### Resolução

Os 2 primeiros bits serão utilizados como byte offset, mas nesse caso sempre serão  0 0 para pegar o primeiro byte de uma palavra. Logo em seguida, viria o _word offset_, como sabemos que cada bloco ocupa 8 bytes e temos palavras de 4 bytes, podemos inferir que são 2 palavras por bloco, então usaremos apenas um bit para o _word offset_. Também temos a informação de que a cache possui apenas 4 blocos de memória, então usaremos 2 bits para representar o index, por último sobram 11 bits para representar a tag.

Estrutura de um endereço: `[tag]¹¹ [index]² [word offset]¹ [byte offset]²`

```
[0 0 0 0 0 0 0 0 0 0 0] [0 1] [1] [0 0].
[0 0 0 0 0 0 1 0 1 1 0] [1 0] [0] [0 0].
[0 0 0 0 0 0 0 0 1 0 1] [0 1] [1] [0 0].
[0 0 0 0 0 0 0 0 0 0 0] [0 1] [0] [0 0].
[0 0 0 0 0 0 1 0 1 1 1] [1 1] [1] [0 0].
[0 0 0 0 0 0 0 1 0 1 1] [0 0] [0] [0 0].
[0 0 0 0 0 0 1 0 1 1 1] [1 1] [0] [0 0].
[0 0 0 0 0 0 0 0 0 0 1] [1 1] [0] [0 0].
[0 0 0 0 0 0 1 0 1 1 0] [1 0] [1] [0 0].
[0 0 0 0 0 0 0 0 1 0 1] [1 0] [0] [0 0].
[0 0 0 0 0 0 1 0 1 1 1] [0 1] [0] [0 0]
[0 0 0 0 0 0 1 1 1 1 1] [1 0] [1] [0 0]
[0 0 0 0 0 0 0 0 1 0 1] [0 1] [0] [0 0]
```

Acessos: 

1. Tag: `[0 0 0 0 0 0 0 0 0 0 0]`, Index: `[0 1]`, Palavra `[1]`, Byte `[0 0]`

Miss, não tem nada naquele lugar da cache ainda, carrega o bloco no espaço 1.

2. Tag: `[0 0 0 0 0 0 1 0 1 1 0]`, Index: `[1 0]`, Palavra `[1]`, Byte `[0 0]`

Miss, não tem nada naquele lugar da cache ainda, carrega o bloco no espaço 2.

3. Tag: `[0 0 0 0 0 0 0 0 1 0 1]`, Index: `[0 1]`, Palavra `[1]`, Byte `[0 0]`

Miss, existe um bloco naquele lugar, mas a tag não bate, exclui o antigo, carrega o bloco no espaço 1.

4. Tag: `[0 0 0 0 0 0 0 0 0 0 0]`, Index: `[0 1]`, Palavra `[1]`, Byte `[0 0]`

Miss, existe um bloco naquele lugar, mas a tag não bate, exclui o antigo, carrega o bloco no espaço 1.

5. Tag: `[0 0 0 0 0 0 1 0 1 1 1]`, Index: `[1 1]`, Palavra `[1]`, Byte `[0 0]`

Miss, não tem nada naquele lugar da cache ainda, carrega o bloco no espaço 3.

6. Tag: `[0 0 0 0 0 0 0 1 0 1 1]`, Index: `[0 0]`, Palavra `[0]`, Byte `[0 0]`

Miss, não tem nada naquele lugar da cache ainda, carrega o bloco no espaço 0.

7. Tag: `[0 0 0 0 0 0 1 0 1 1 1]`, Index: `[1 1]`, Palavra `[0]`, Byte `[0 0]`

Hit, tag bate com o bloco que estava no local, mesmo que palavra seja diferente, ela ainda estava carregada no mesmo bloco.

8. Tag: `[0 0 0 0 0 0 0 0 0 0 1]`, Index: `[1 1]`, Palavra `[0]`, Byte `[0 0]`

Miss, existe um bloco naquele lugar, mas a tag não bate, exclui o antigo, carrega o bloco no espaço 3.

9. Tag: `[0 0 0 0 0 0 1 0 1 1 0]`, Index: `[1 0]`, Palavra `[1]`, Byte `[0 0]`

Hit, tag bate com o bloco que estava no local, mesmo que palavra seja diferente, ela ainda estava carregada no mesmo bloco.

10. Tag: `[0 0 0 0 0 0 0 0 1 0 1]`, Index: `[1 0]`, Palavra `[0]`, Byte `[0 0]`

Miss, existe um bloco naquele lugar, mas a tag não bate, exclui o antigo, carrega o bloco no espaço 2.

11. Tag: `[0 0 0 0 0 0 1 0 1 1 1]`, Index: `[0 1]`, Palavra `[0]`, Byte `[0 0]`

Miss, existe um bloco naquele lugar, mas a tag não bate, exclui o antigo, carrega o bloco no espaço 1.

12. Tag: `[0 0 0 0 0 0 1 1 1 1 1]`, Index: `[0 1]`, Palavra `[1]`, Byte `[0 0]`

Miss, existe um bloco naquele lugar, mas a tag não bate, exclui o antigo, carrega o bloco no espaço 1.

13. Tag: `[0 0 0 0 0 0 0 0 1 0 1]`, Index: `[1 1]`, Palavra `[0]`, Byte `[0 0]`

Miss, existe um bloco naquele lugar, mas a tag não bate, exclui o antigo, carrega o bloco no espaço 3.

Resultado final: 7 subs, 2 hits, 11 miss.