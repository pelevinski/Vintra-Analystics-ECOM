# Demanda 001 — Limpeza de Dados + Faturamento por Canal de Venda

**Data:** 23/09/2026
**Solicitante (simulado):** Diretoria Comercial
**Objetivo:** Apoiar a decisão sobre em qual canal de venda investir mais no 2º semestre — Marketplace ou Site Próprio.

## Contexto

A base de vendas recebida tinha inconsistências típicas de um ambiente real: pedidos duplicados, campos obrigatórios sem preenchimento e falta de padronização em um campo de texto. Antes de qualquer análise, foi necessário limpar e documentar cada decisão de tratamento — já que escolhas diferentes aqui mudam o resultado final do relatório.

## Problemas encontrados e decisões tomadas

| Problema | Decisão | Justificativa |
|---|---|---|
| Pedidos duplicados (`id_pedido` repetido) | Removidos via `drop_duplicates(subset='id_pedido')` | `id_pedido` é chave primária — um mesmo ID aparecer duas vezes é sempre erro de gravação, nunca uma venda legítima repetida (um novo pedido sempre gera um novo ID) |
| `quantidade` nula (20 linhas) | Linhas removidas via `dropna(subset=['quantidade'])` | A tabela não possui coluna de valor total da venda — sem `quantidade`, não há como recalcular o faturamento dessas linhas por nenhum outro caminho |
| `desconto_pct` nulo (938 linhas) | Tratado como 0% via `fillna(0)` | Ausência de registro de desconto foi interpretada como "sem desconto aplicado" — diferente de `quantidade`, aqui o nulo tem um significado de negócio claro, não precisa ser descartado |
| Abreviação de estado sem padrão (maiúsculo/minúsculo) | Padronizado para maiúsculo via `str.upper()` | Consistência para agrupamentos e futuras análises geográficas |
| `status_pedido` (Cancelado, Devolvido, Em Processamento) | Apenas `Concluído` considerado no faturamento | Faturamento deve refletir apenas vendas efetivamente concretizadas — prática padrão de reconhecimento de receita |

## Pipeline de tratamento (Python)

O tratamento foi feito em Python/pandas (`tratamento_dados.ipynb`), a partir da base bruta em Excel, seguindo esta ordem:

1. Leitura de todas as abas do Excel bruto (`vintra_base_dados.xlsx`)
2. Preenchimento de `desconto_pct` nulo com 0 (**antes** da remoção por `quantidade`, já que são colunas independentes e tratadas com critérios diferentes)
3. Remoção das linhas com `quantidade` nula (`dropna(subset=['quantidade'])`)
4. Remoção de duplicatas por `id_pedido`
5. Padronização de `estado` para maiúsculo na tabela Clientes
6. Exportação do resultado consolidado (`vintra_dados_tratado.xlsx`) e, em seguida, quebra em um CSV por aba (Vendas, Clientes, Produtos, Vendedores) — formato mais simples de importar no PostgreSQL do que um Excel com múltiplas abas

**Nota de consistência:** numa primeira rodada, o tratamento de `quantidade` havia sido feito com `fillna(0)` em vez de remoção, e essas 20 linhas acabaram sendo corrigidas manualmente direto no banco via `DELETE FROM vendas WHERE quantidade = 0`. O notebook já foi corrigido para tratar isso na origem — cargas futuras não vão precisar dessa correção manual no banco.

## Erro identificado e corrigido

Na primeira versão do relatório, a soma dos pedidos mensais (Jan + Fev + Mar) não batia com o total do trimestre — uma diferença de 8 pedidos entre os canais.

**Causa raiz:** a query de Janeiro usava `BETWEEN '2026-01-01' AND '2026-01-30'`, excluindo por engano o dia 31 de janeiro (mês que tem 31 dias). Após a correção do filtro de data, a soma dos meses passou a bater exatamente com o total do trimestre em todos os canais.

Esse processo reforçou um hábito que passou a ser padrão nas entregas seguintes: **sempre reconciliar a soma das partes com o total antes de enviar um relatório.**

## Resultados

### Faturamento por canal (Jan–Mar 2026)

| Canal | Faturamento |
|---|---|
| Marketplace B | R$ 1.138.499,78 |
| Loja Física | R$ 1.117.724,18 |
| Site Próprio | R$ 1.089.952,96 |
| App Mobile | R$ 1.054.925,87 |
| Marketplace A | R$ 985.813,40 |

### Ticket médio por canal

| Canal | Ticket Médio |
|---|---|
| Marketplace B | R$ 3.171,31 |
| Site Próprio | R$ 3.168,47 |
| Loja Física | R$ 3.045,57 |
| App Mobile | R$ 2.988,46 |
| Marketplace A | R$ 2.800,61 |

### Crescimento acumulado de pedidos (Jan → Mar)

| Canal | Variação |
|---|---|
| App Mobile | +20,37% |
| Marketplace B | +19,27% |
| Marketplace A | +15,89% |
| Site Próprio | +9,91% |
| Loja Física | -3,79% |

## Recomendação

A pergunta original da diretoria ("em qual canal investir") depende de um critério de negócio que não estava explícito no pedido — por isso, a resposta foi condicionada a dois cenários possíveis:

- **Se o objetivo é recuperar um canal em queda:** Site Próprio — cresceu 9,91% no trimestre, mas ainda abaixo dos líderes.
- **Se o objetivo é acelerar o canal mais promissor:** Marketplace B ou App Mobile — maior faturamento e maior crescimento acumulado, respectivamente.

## Aprendizados

- Documentar cada decisão de tratamento de dado é tão importante quanto o tratamento em si — protege o analista e dá transparência a quem consome o relatório.
- Reconciliar soma das partes com o total é uma verificação simples que evita entregar números errados.
- Quando uma pergunta de negócio depende de um critério não informado, a resposta certa não é adivinhar — é tornar essa dependência explícita no relatório.
- Nulos em colunas diferentes podem exigir tratamentos opostos (remover vs. preencher) — a decisão depende se o dado é recuperável por outra via e se o nulo tem um significado de negócio.
- Manter a lógica de tratamento concentrada em um único lugar (o notebook, na origem dos dados) evita que regras de negócio fiquem espalhadas e dessincronizadas entre Python e banco de dados.

## Arquivos desta pasta

- `tratamento_dados.ipynb` — notebook com a limpeza e padronização da base bruta
- `queries.sql` — queries SQL usadas para gerar as métricas do relatório
- `README.md` — este documento
