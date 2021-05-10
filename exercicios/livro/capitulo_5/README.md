# Capitulo 5 - Large and fast: exploiting memory hierarchy

### 5.1

In this exercise we look at memory locality properties of matrix computation. The following code is written in C, where elements within the same row are stored contiguously. Assume each word is a 32-bit integer.

```c
for (I=0; I<8; I++) {
    for (J=0; J<8000; J++) {
        A[I][J]=B[I][0]+A[J][I];
    }
}
```

Locality is aff ected by both the reference order and data layout. The same computation can also be written below in Matlab, which differs from C by storing matrix elements within the same column contiguously in memory.

```matlab
for I=1:8
    for J=1:8000
        A(I,J)=B(I,0)+A(J,I);
    end
end
```

#### 5.1.1

How many 32-bit integers can be stored in a 16-byte cache block?

**Resposta:**

Considerando que cada inteiro vai ocupar 4 bytes, um bloco de 16 bytes pode comportar 4 inteiros.

#### 5.1.2

References to which variables exhibit temporal locality? (Código em C)

**Resposta:**

I e J são referênciados nos laços a todo momento, portanto apresentam localidade temporal

#### 5.1.3

References to which variables exhibit spatial locality? (Código em C)

**Resposta:**

A[I][J], no laço mais interno do programa J é incrementado 8 mil vezes para acessar 8 mil posições de uma lista que estão contíguas em memória (pois C é row-major).

#### 5.1.4

How many 16-byte cache blocks are needed to store all 32-bit matrix elements being referenced?

**Resposta:**

Considerando que eu tenho `8 x 8000` números e que cada um ocupa 4 bytes temos `6400 * 4 bytes = 25600 bytes`, dividindo por 16 bytes temos 1600 blocos necessário para guardar a memória toda em cache.

#### 5.1.5

References to which variables exhibit temporal locality? (Código em matlab)

**Resposta:**

Nesse caso, nada mudou, I e J são referênciados nos laços a todo momento, portanto apresentam localidade temporal

#### 5.1.6

References to which variables exhibit spatial locality? (Código em matlab)

Dessa vez, o matlab guarda as colunas de uma matriz contiguamente em memória, portanto no nosso código A(J, I) apresenta localidade espacial.

#### 5.2

Caches are important to providing a high-performance memory hierarchy to processors. Below is a list of 32-bit memory address references, given as word addresses.

| 3   | 180 | 43  | 2   | 191 | 88  | 190 | 14  | 181 | 44  | 186 | 253 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

#### 5.2.1

For each of these references, identify the binary address, the tag, and the index given a direct-mapped cache with 16 one-word blocks. Also list if each reference is a hit or a miss, assuming the cache is initially empty.

**Resposta:**

Primeiro, o exercício diz que os números estão dados como `word address` então os 2 primeiros bits (byte offset) devem ser ignorados, se o exercício tivesse nos dado um `byte address` então contariamos os 32 bits. Para ignorar esses bits nós basicamente escrevemos um número de 30 bits com os dados passados pelo exercício e depois adicionamos `XX` a esquerda para simbolizar os bits ignorados.

Depois disso, podemos pensar na estrutura desse endereço, o exercício diz que é uma cache de 16 posições e uma palavra por bloco, assim sabemos que temos 0 bits de `word offset` e 4 bits de `index`, 2 de `byte offset` (que representaremos com o XX) e o que sobrou é a `tag`.

| Tag     | Index  | Word offset | Byte offset |
| ------- | ------ | ----------- | ----------- |
| 26 bits | 4 bits | 0 bits      | 2 bits      |

Com esses dados podemos montar uma tabela com os endereços em binário e ir "adicionando" eles na cache. Era visível desde o começo que não teriamos hits pois estamos usando uma cache de 1 palavra por bloco (não aproveitamos localidade espacial) e todos os acessos são feitos em endereços diferentes (não há localidade temporal). Na tabela abaixo temos a resposta desse exercício, mas perceba que o `word address` tem 32 bits e a `tag` tem 26, os bits que não foram representados na tabela estão a esquerda e são todos 0.

| Access | Word address (Decimal) | Word Address (Binary) | Tag                 | Index       |
| ------ | ---------------------- | --------------------- | ------------------- | ----------- |
| 1      | 3                      | `0000 0000 11XX`      | `0000 0000 00` (0)  | `0011` (3)  |
| 2      | 180                    | `0010 1101 00XX`      | `0000 0010 11` (11) | `0100` (4)  |
| 3      | 43                     | `0000 1010 11XX`      | `0000 0000 10` (2)  | `1011` (11) |
| 4      | 2                      | `0000 0000 10XX`      | `0000 0000 00` (0)  | `0010` (2)  |
| 5      | 191                    | `0010 1111 11XX`      | `0000 0010 11` (11) | `1111` (15) |
| 6      | 88                     | `0001 0110 00XX`      | `0000 0001 01` (5)  | `1000` (8)  |
| 7      | 190                    | `0010 1111 10XX`      | `0000 0010 11` (11) | `1110` (14) |
| 8      | 14                     | `0000 0011 10XX`      | `0000 0000 00` (0)  | `1110` (14) |
| 9      | 181                    | `0010 1101 01XX`      | `0000 0010 11` (11) | `0101` (5)  |
| 10     | 44                     | `0000 1011 00XX`      | `0000 0000 10` (2)  | `1100` (12) |
| 11     | 186                    | `0010 1110 10XX`      | `0000 0010 11` (11) | `1010` (10) |
| 12     | 186                    | `0011 1111 01XX`      | `0000 0011 11` (15) | `1101` (13) |

### 5.2.2

For each of these references, identify the binary address, the tag, and the index given a direct-mapped cache with two-word blocks and a total size of 8 blocks. Also list if each reference is a hit or a miss, assuming the cache is initially empty.

**Resposta:** 

Dessa vez o exercício pede para repetir o que fizemos antes em uma cache de duas palavras por bloco e 8 blocos totais, isso vai mudar bastante coisa no resultado então vamos começar refazendo a estrutura do endereço. Dessa vez temos um bit para `word offset` e 3 bits para o `index`, 2 de `byte offset` e o que sobra novamente é a `tag`.

| Tag     | Index  | Word offset | Byte offset |
| ------- | ------ | ----------- | ----------- |
| 26 bits | 3 bits | 1 bits      | 2 bits      |

| Access | Word address (Decimal) | Word Address (Binary)    | Tag            | Index   | Word offset |
| ------ | ---------------------- | ------------------------ | -------------- | ------- | ----------- |
| 1      | 3                      | `0000 00` `001` `1` `XX` | `00 0000` (0)  | 001 (1) | 1           |
| 2      | 180                    | `0010 11` `010` `0` `XX` | `00 1011` (11) | 010 (2) | 0           |
| 3      | 43                     | `0000 10` `101` `1` `XX` | `00 0010` (2)  | 101 (5) | 1           |
| 4      | 2                      | `0000 00` `001` `0` `XX` | `00 0000` (0)  | 001 (1) | 0           |
| 5      | 191                    | `0010 11` `111` `1` `XX` | `00 1011` (11) | 111 (7) | 1           |
| 6      | 88                     | `0001 01` `100` `0` `XX` | `00 0101` (5)  | 100 (4) | 0           |
| 7      | 190                    | `0010 11` `111` `0` `XX` | `00 1011` (11) | 111 (7) | 0           |
| 8      | 14                     | `0000 00` `111` `0` `XX` | `00 0000` (0)  | 111 (7) | 0           |
| 9      | 181                    | `0010 11` `010` `1` `XX` | `00 1011` (11) | 010 (2) | 1           |
| 10     | 44                     | `0000 10` `110` `0` `XX` | `00 0010` (2)  | 110 (6) | 0           |
| 11     | 186                    | `0010 11` `101` `0` `XX` | `00 1011` (11) | 101 (5) | 0           |
| 12     | 186                    | `0011 11` `110` `1` `XX` | `00 1111` (15) | 110 (6) | 1           |

Agora precisamos ver quantos misses e hits vamos ter na inserção sequencial desses valores. Vou fazer acesso por acesso só pra entendermos melhor o que ta acontecendo, lembrando que a cache começa "vazia", com todos os bits de validade setados pra 0.

1. Miss, adiciona o bloco com tag 0 no indice 1
2. Miss, adiciona o bloco com tag 11 no indice 2
3. Miss, adiciona o bloco com tag 2 no indice 5
4. Hit.
5. Miss, adiciona o bloco com tag 11 no indice 7
6. Miss, adiciona o bloco com tag 5 no indice 4
7. Hit.
8. Miss, adiciona o bloco com a tag 0 no indice 7.
9. Hit.
10. Miss, adiciona o bloco com a tag 2 no indice 6.
11. Miss, adiciona o bloco com a tag 11 no indice 5.
12. Miss, adicioan o bloco com a tag 15 no indice 6


### 5.3

For a direct-mapped cache design with a 32-bit address, the following bits of the address are used to access the cache.

| Tag   | Index | Offset |
| ----- | ----- | ------ |
| 31-10 | 9-5   | 4-0    |

#### 5.3.1

What is the cache block size (in words)?

**Resposta:**

Se temos 5 bits pra representar o offset e 2 deles são necessariamente o `byte offset` então os 3 que sobram nos dizem que temos 8 palavras por bloco, já que `log₂(8) = 3`.

#### 5.3.2

How many entries does the cache have?

**Resposta:**

Considerando que também temos 5 bits para representar, a cache possui 32 entradas já que `log₂(32) = 5`.

#### 5.3.3

What is the ratio between total bits required for such a cache implementation over the data storage bits?

**Resposta:**

Pra calcular isso, precisamos calcular a quantidade total de bits na cache (junto com o custo de administração) e a capacidade de dados da cache primeiro.

1. Custo total

Vamos calcular aqui supondo 32 blocos na cache, uma tag de 22 bits, 8 palavras de 32 bits e um bit de validade. Note que não estamos usando `dirty bit` nem o bit do LRU.

```
Custo = 32 * [22 + (8 * 32) + 1] 
Custo = 32 * 279
Custo = 8928 bits
```

2. Capacidade

Para calcular a capacidade é só removermos os bits que são usados para administração da cache, nesse caso são os bits da `tag`e o bit de validade.

```
Capacidade = 32 * 8 * 32
Capacidade = 8192 bits
```

O ratio é simplesmente a divisão entre esses dois valores, `8928 / 8192 ≈ 1.08`, um ratio relativamente baixo que mostra que a cache possui uma boa eficiência. Obviamente essa cache não tem valores reais então não serve pra nada.

#### 5.3.4

Starting from power on, the following byte-addressed cache references are recorded.

| 0   | 4   | 16  | 132 | 232 | 160 | 1024 | 30  | 140 | 3100 | 180 | 2180 |
| --- | --- | --- | --- | --- | --- | ---- | --- | --- | ---- | --- | ---- |

How many blocks are replaced?

**Resposta:**

Dessa vez o exercício nos deu `byte addressess` então vamos considerar esse endereço como sendo o número de 32 bits completo. Faremos o mesmo que no exercício **5.2** e vamos criar uma tabela com os valores em binário pra facilitar o exercício

| Access | Byte Address                                       | Tag                      | Index       | Word offset | Byte offset |
| ------ | -------------------------------------------------- | ------------------------ | ----------- | ----------- | ----------- |
| 1      | `0000000000000000000000` `00000` `000` `00` (0)    | `0000000000000000000000` | `00000` (0) | `000`       | `00`        |
| 2      | `0000000000000000000000` `00000` `001` `00` (4)    | `0000000000000000000000` | `00000` (0) | `001`       | `00`        |
| 3      | `0000000000000000000000` `00000` `100` `00` (16)   | `0000000000000000000000` | `00000` (0) | `100`       | `00`        |
| 4      | `0000000000000000000000` `00100` `001` `00` (132)  | `0000000000000000000000` | `00100` (4) | `001`       | `00`        |
| 5      | `0000000000000000000000` `00111` `010` `00` (232)  | `0000000000000000000000` | `00111` (7) | `010`       | `00`        |
| 6      | `0000000000000000000000` `00101` `000` `00` (160)  | `0000000000000000000000` | `00101` (5) | `000`       | `00`        |
| 7      | `0000000000000000000001` `00000` `000` `00` (1024) | `0000000000000000000001` | `00000` (0) | `000`       | `00`        |
| 8      | `0000000000000000000000` `00000` `111` `10` (30)   | `0000000000000000000000` | `00000` (0) | `111`       | `10`        |
| 9      | `0000000000000000000000` `00100` `011` `00` (140)  | `0000000000000000000000` | `00100` (4) | `011`       | `00`        |
| 10     | `0000000000000000000011` `00000` `111` `00` (3100) | `0000000000000000000011` | `00000` (0) | `111`       | `00`        |
| 11     | `0000000000000000000000` `00101` `101` `00` (180)  | `0000000000000000000000` | `00101` (5) | `101`       | `00`        |
| 12     | `0000000000000000000010` `00100` `001` `00` (2180) | `0000000000000000000010` | `00100` (4) | `001`       | `00`        |

1. Miss, carrega bloco com a tag 0 no índice 0
2. Hit.
3. Hit.
4. Miss, carrega bloco com a tag 0 no índice 4
5. Miss, carrega bloco com a tag 0 no índice 7
6. Miss, carrega bloco com a tag 0 no índice 5
7. Miss, carrega bloco com a tag 1 no índice 0 (substituição)
8. Miss, carrega bloco com a tag 0 no índice 0 (substituição)
9. Hit.
10. Miss, carrega bloco com a tag 3 no índice 0
11. Hit.
12. Miss, carrega o bloco com a tag 2 no índice 4 (substituição)

Chegamos em um total de 3 substituições de blocos nessa sequência de acessos.

#### 5.3.5

What is the hit ratio?

**Resposta:** 

O hit ratio é a quantidade de hits dividida pela quantidade de acessos, tivemos 4 hits em 12 acessos então hit ratio é `4/12 = 3.333`.

#### 5.3.5

List the final state of the cache, with each valid entry represented as a record of (index, tag, data).

**Resposta:**

Isso aqui dá muito trabalho então não vou fazer de jeito nenhum, mas fica uma dica pra quem quiser fazer: só temos acessos em 4 índices diferentes da cache, represente o estado deles ao final do passo 12. Todos os outros indices vão ter o bit de validade em 0 então tudo que tiver ali dentro é lixo.

### 5.6

In this exercise, we will look at the diff erent ways capacity aff ects overall performance. In general, cache access time is proportional to capacity. Assume that main memory accesses take 70 ns and that memory accesses are 36% of all instructions. The following table shows data for L1 caches attached to each of two processors, P1 and P2.

| Processor | L1 Size | L1 Miss Rate | L1 Hit Time |
| --------- | ------- | ------------ | ----------- |
| P1        | 2 KiB   | 8.0%         | 0.66ns      |
| P2        | 4 KiB   | 6.0%         | 0.90ns      |

#### 5.6.1

Assuming that the L1 hit time determines the cycle times for P1 and P2, what are their respective clock rates?

**Resposta:**

```
F(P1) = 1 / (0.66 * 10⁻⁹) 
F(P1) = (1 / 0.66) * (10⁰ / 10⁻⁹)
F(P1) = 1,51 * 10⁹ = 1,51 GHz
```

```
F(P2) = 1 / (0.90 * 10⁻⁹) 
F(P2) = (1 / 0.90) * (10⁰ / 10⁻⁹)
F(P2) = 1,1 * 10⁹ = 1,11 GHz
```

#### 5.6.2

What is the Average Memory Access Time for P1 and P2?

**Resposta:**

O tempo médio de acesso a memória (AMAT) é uma métrica calculada por `hit time + (miss ratio * miss penalty)`

```
AMAT(P1) = 0.66 ns + (0.08 * 70 ns) = 6.26 ns
```

```
AMAT(P2) = 0.9 + (0.06 * 70 ns) = 5.1 ns
```

#### 5.6.3

Assuming a base CPI of 1.0 without any memory stalls, what is the total CPI for P1 and P2? Which processor is faster?

**Resposta:**

Precisamos calcular o CPI total levando em consideração apenas stalls gerados por faltas na cache, então iremos ignorar qualquer tipo de stall gerado por problemas no pipeline

- **P1**

```
CPI(Total) = CPI(Base) + CPI(Stalls)
```

O CPI gerado por stalls pode ser calculado como:

```
CPI(Stalls) = Acessos * Penalidade * Taxa de erros
```

Mas ainda precisamos descobrir quantos ciclos de penalidade temos, sabemos apenas que o P1 possui um período de 0.66ns e uma busca em MP leva 70ns para ser feita. Se dividirmos esses 2 valores vamos chegar em 106 ciclos de penalidade. Agora podemos calcular o CPI gerado por stalls

```
# 1 + 0.36 representam acessos a instruções + acessos a dados

CPI(Stalls) = (1 + 0.36) * 106 * 0.08 = 11.5328
```

Agora podemos dizer que o CPI(Total) é dado por

```
CPI(Total) = 1 + 11.53 = 12.5328
```

- **P2**

Como o P2 possui um período diferente de P1, precisamos recalcular a penalidade em ciclos, dividindo 70 por 0.9 temos 78 ciclos de penalidade (arredondando pra cima já que não existe "meio ciclo").

```
# 1 + 0.36 representam acessos a instruções + acessos a dados

CPI(Stalls) = (1 + 0.36) * 78 * 0.06 = 6.3648
```

E finalmente chegamos no CPI(Total)

```
CPI(Total) = 1 + 6.3648 = 7.3648
```

No final, descobrimos que P2 é mais rápido.

> For the next three problems, we will consider the addition of an L2 cache to P1 to presumably make up for its limited L1 cache capacity. Use the L1 cache capacities and hit times from the previous table when solving these problems. The L2 miss rate indicated is its local miss rate.

| L2 Size | L2 Miss Rate | L2 Hit Time |
| ------- | ------------ | ----------- |
| 1 MiB   | 95%          | 5.62ns      |

#### 5.6.4

What is the AMAT for P1 with the addition of an L2 cache? Is the AMAT better or worse with the L2 cache?

**Resposta:** 

Adicionando a nova cache precisamos modificar um pouco nossa conta, o AMAT será `HitTime(L1) + MR(L1) * [ HitTime(L2) +  MR(L2) * Penalidade ]`

```
AMAT(P1) = 0.66 ns + 0.08 * (5.62 ns + 0.95 * 70 ns) = 6.4296 ns
```

O valor é um pouco maior do que considerando apenas a cache L1.

#### 5.6.5

Assuming a base CPI of 1.0 without any memory stalls, what is the total CPI for P1 with the addition of an L2 cache?

**Resposta:**

```
CPI(Total) = CPI(Base) + CPI(Stalls)
```

O CPI base já é dado pelo problema então precisamos agora calcular o CPI gerado por stalls, antes disso precisamos calcular a penalidade que precisamos pagar para ir até a cache L2, como ela tem um hit time de 5.62ns e temos um período de 0.66ns chegamos em uma penalidade de 9 ciclos (8.51 arredondados pra cima).

```
CPI(Stalls) = Acessos * MR(L1) * (Penalidade(L2) + MR(l2) + Penalidade(MP))
CPI(Stalls) = (1 + 0.36) * 0.08 * (9 + 0.95 * 106)
CPI(Stalls) = 1.36 * 0.08 * 109.7
CPI(Stalls) = 11.9353
```

Agora podemos calcular o CPI total

```
CPI(Total) = CPI(Base) + CPI(Stalls)
CPI(Total) = 1 + 11.9353
CPI(Total) = 12.9353
```