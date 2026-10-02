# Demanda 002 — Margem de Lucro e Priorização por Categoria

**Data:** 24–30/09/2026
**Solicitante (simulado):** Time de Marketing
**Objetivo:** Definir em quais categorias de produto priorizar o investimento da campanha do 2º trimestre, considerando verba limitada.

## Contexto

Diferente da demanda 001, esta análise exigiu `JOIN` entre as tabelas `vendas` e `produtos`, já que margem e lucro dependem de `preco_custo` e `preco_venda`, que só existem na tabela de produtos.

## Decisões de cálculo

| Métrica | Fórmula | Por quê |
|---|---|---|
| Faturamento | `quantidade * preco_unitario * (1 - desconto_pct)` | Faturamento líquido, refletindo o desconto efetivamente concedido |
| Margem de lucro | `(preço_venda - preço_custo) / preço_venda` | Mede "de cada R$1 vendido, quanto é lucro" — diferente de markup, que divide pelo custo |
| Lucro bruto | `quantidade * (preço_venda - preço_custo)` | Precisa multiplicar pela quantidade vendida, não só pela margem unitária do produto |
| Desconto no lucro | Aplicado também no lucro, não só no faturamento | Para manter faturamento e lucro na mesma base de cálculo e a margem % consistente |

## Erros identificados e corrigidos durante o desenvolvimento

Esta demanda passou por mais de uma rodada de correção até fechar:

1. **Desconto tratado como subtração direta** (`preco - desconto_pct`) em vez de percentual (`preco * (1 - desconto_pct)`) — corrigido.
2. **Lucro bruto por categoria sem multiplicar pela quantidade vendida** — a query inicial somava a margem unitária do produto uma vez por pedido, ignorando quantas unidades foram vendidas em cada pedido.
3. **Numerador e denominador da margem em bases diferentes** — o lucro era calculado sobre o preço cheio enquanto o faturamento já considerava desconto, inflando artificialmente a margem.

## Nota de transparência

Durante a revisão final, uma versão do relatório apresentou uma **divergência entre a tabela de "Lucro Bruto Total por Categoria" e o texto das conclusões**: a tabela mantinha Casa Inteligente em 1º lugar, enquanto o texto já citava Acessórios Mobile na liderança. Essa inconsistência não foi resolvida antes da publicação desta versão — os números abaixo refletem o relatório como foi entregue, e a reconciliação final entre tabela e texto fica como ponto de atenção para revisão futura.

Optei por manter esse registro no README, em vez de silenciar o problema, porque documentar uma inconsistência identificada e não resolvida a tempo é mais honesto — e mais útil como aprendizado — do que apagar o rastro dela.

## Resultados

### Faturamento por categoria (Jan–Mar 2026)

| Categoria | Faturamento |
|---|---|
| Casa Inteligente | R$ 1.529.650,01 |
| Eletrônicos | R$ 1.211.722,97 |
| Acessórios Mobile | R$ 1.096.428,86 |
| Games | R$ 1.013.054,45 |
| Informática | R$ 535.988,60 |

### Margem de lucro por categoria

| Categoria | Margem |
|---|---|
| Acessórios Mobile | 47,89% |
| Games | 43,74% |
| Informática | 37,62% |
| Eletrônicos | 36,30% |
| Casa Inteligente | 34,72% |

### Lucro bruto por categoria

| Categoria | Lucro Bruto |
|---|---|
| Casa Inteligente | R$ 262.779,65 |
| Acessórios Mobile | R$ 247.261,79 |
| Games | R$ 221.536,56 |
| Eletrônicos | R$ 213.639,27 |
| Informática | R$ 106.523,37 |

> ⚠️ Ver "Nota de transparência" acima — o texto de conclusões desta rodada posiciona Acessórios Mobile como líder de lucro bruto, divergindo da tabela.

### Top 5 produtos mais lucrativos

| Produto | Faturamento | Lucro |
|---|---|---|
| Suporte Veicular | R$ 544.152,96 | R$ 271.752,00 |
| Smartwatch | R$ 406.706,93 | R$ 185.329,08 |
| Cadeira Gamer | R$ 326.753,40 | R$ 176.087,85 |
| Assistente Virtual | R$ 404.998,30 | R$ 169.545,74 |
| Power Bank 10000mAh | R$ 270.844,92 | R$ 143.925,84 |

### Top 5 produtos menos vendidos (com estoque)

| Produto | Estoque Atual | Qtd. Vendida |
|---|---|---|
| Fone de Ouvido Bluetooth | 106 | 93 |
| Película de Vidro | 476 | 103 |
| Notebook 14'' | 13 | 107 |
| Capa de Celular | 389 | 109 |
| Mouse sem Fio | 491 | 114 |

Nota: Notebook 14'' tem estoque baixo (13 unidades) apesar de vendas moderadas — não é "dinheiro parado" como os demais da lista, só tem giro naturalmente mais lento por ser um produto de ticket alto.

## Considerações finais

- Produtos com pouca saída e alto estoque parado: Película de Vidro, Capa de Celular, Mouse sem Fio.
- Casa Inteligente lidera faturamento e lucro bruto, mas tem a menor margem percentual entre as categorias.
- Eletrônicos lidera em volume de vendas, mas com margem e lucro bruto relativamente baixos.
- Acessórios Mobile lidera em margem percentual, mas vende proporcionalmente menos unidades.

## Recomendação para o Marketing

- **Priorizar lucro bruto absoluto** como critério principal, já que a verba é limitada e precisa gerar retorno em R$ para a empresa.
- **Casa Inteligente** como categoria carro-chefe, com atenção à melhoria de margem.
- **Eletrônicos** como segunda prioridade, com revisão de precificação (indício de estar sendo vendida "barata" frente ao mercado).
- **Acessórios Mobile** como categoria a monitorar de perto — a alta margem pode estar restringindo o volume de vendas; ajustes aqui podem destravar bastante rentabilidade.
- Campanha de cupons/desconto para os produtos parados em estoque (item 1).

## Aprendizados

- Fórmulas de desconto percentual exigem multiplicação `(1 - taxa)`, nunca subtração direta.
- Métricas que serão comparadas entre si (como lucro e faturamento numa razão de margem) precisam estar calculadas na mesma base — misturar valores brutos e líquidos distorce o resultado.
- Nem toda correção sai certa de primeira — às vezes uma correção resolve um problema e introduz outro (ex: a correção de quantidade no lucro bruto acabou colando a fórmula de faturamento por engano). Validar o resultado após cada mudança, não só a lógica da fórmula, é essencial.
- Quando o prazo aperta e uma inconsistência não dá tempo de ser resolvida, documentá-la com transparência é melhor do que publicar como se estivesse tudo certo.

## Arquivos desta pasta

- `queries.sql` — queries finais corrigidas
- `README.md` — este documento
