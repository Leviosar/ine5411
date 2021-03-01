# Jump Address Table (JAT)

Vimos na aula [04.1](./aex04.1.md) como implementar estruturas do tipo `if-else` e `loops` utilizando desvios condicionais e incondicionais, mas acabou faltando uma outra estrutura muito utilizada em linguagens de alto nível a ser explicada, o `switch case`. Pra ser bem justo, da mesma forma que você você pode implementar um `switch` como uma série de `if-elses` aninhados em uma linguagem de alto nível, o compilador poderia compilar uma estrutura `switch` dessa forma. Entretanto, adicionar muitos desvios num programa vai tornar ele mais lento, por isso temos o que chamamos de `Jump Address Table`, uma alternativa de implementação em baixo nível para `switchs`.

Você pode ver um exemplo implementado dessa alternativa no [Laboratório 2](./../trabalhos/laboratorio/lab_2).