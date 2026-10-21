# Demanda 003 — Performance de Vendedores vs. Meta (Q2/2026)

**Data:** Outubro/2026
**Solicitante (simulado):** Diretoria Comercial
**Objetivo:** Analisar o desempenho dos vendedores e das equipes comerciais no 2º trimestre de 2026 (abril, maio e junho) para subsidiar a revisão do plano de comissionamento.

---

## Contexto

A Diretoria Comercial solicitou um diagnóstico sobre quais vendedores e equipes bateram meta no Q2/2026, com foco em identificar destaques positivos e gargalos operacionais. 

Como o pedido original continha termos intencionalmente vagos ("melhor" e "pior" vendedor), foi necessário definir critérios claros de cálculo em SQL, além de criar uma camada de automação (`VIEW`) para padronizar o cálculo de faturamento líquido.

---

## Critérios Adotados

| Critério | Definição / Regra de Negócio em SQL | Justificativa |
|---|---|---|
| **Base de Faturamento Líquido** | `quantidade * preco_unitario * (1 - COALESCE(desconto_pct, 0))` em pedidos com status `'Concluído'`. | Evita distorções causadas por pedidos cancelados/devolvidos e garante que o desconto seja abatido corretamente. |
| **Meta Atingida** | Faturamento líquido mensal do vendedor $\ge$ `meta_mensal`. | Critério objetivo direto para contagem de meses de sucesso. |
| **"Melhor / Pior Vendedor"** | Avaliado pela **consistência** (quantidade de meses atingidos no trimestre) e pelo **ranking relativo na equipe** (`RANK() OVER (PARTITION BY equipe)`). | Evita o viés de comparar faturamentos absolutos entre vendedores que possuem metas de tamanhos diferentes. |
| **Métrica de Tendência** | Comparação mês a mês usando `LAG(pct_atingimento)` no SQL. | Permite identificar a evolução real da eficiência do vendedor em relação à sua meta (Melhorando vs. Piorando), independentemente de oscilações gerais do mercado. |
| **Situação da Equipe** | Regra de negócio categorizada por percentual de atingimento trimestral acumulado: $\ge 110\%$ (Destaque), $\ge 100\%$ (Meta atingida), $\ge 95\%$ (Próximo da meta) e $< 95\%$ (Abaixo da meta). | Traz clareza rápida para a tomada de decisão da diretoria comercial. |

---

## Registros de Dúvidas e Ambiguidades

1. **Definição Absoluta vs. Relativa de "Melhor Vendedor":** Um vendedor pode faturar R$ 180k em um mês e não bater sua meta de R$ 200k, enquanto outro fatura R$ 110k e bate uma meta de R$ 100k. Optou-se por **privilegiar o percentual de atingimento da meta**, por estar diretamente atrelado ao plano de comissionamento e expectativas da empresa.
2. **Estabilidade de Metas** Assumiu-se que a meta de equipe permaneceram constantes ao longo dos 3 meses do Q2/2026.
3. **Filtro de Status:** Consideraram-se apenas pedidos com status `'Concluído'`. Pedidos pendentes ou cancelados foram excluídos da base da `VIEW`.

---

## Resultados

### 1. Desempenho Mensal por Vendedor (Abril, Maio e Junho / 2026)

| ID Vendedor | Meta Mensal | Fat. Abr/26 | % Abr | Fat. Mai/26 | % Mai | Fat. Jun/26 | % Jun | Meses Meta Batida |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **1** | R$ 110.000 | R$ 109.487,56 | 99,53% | R$ 133.116,77 | 121,02% | R$ 115.624,71 | 105,11% | **2** |
| **2** | R$ 130.000 | R$ 129.524,96 | 99,63% | R$ 101.845,12 | 78,34% | R$ 140.916,34 | 108,40% | **1** |
| **3** | R$ 150.000 | R$ 137.575,81 | 91,72% | R$ 125.424,66 | 83,62% | R$ 152.464,64 | 101,64% | **1** |
| **4** | R$ 120.000 | R$ 112.236,81 | 93,53% | R$ 140.504,19 | 117,09% | R$ 140.379,67 | 116,98% | **2** |
| **5** | R$ 125.000 | R$ 113.924,16 | 91,14% | R$ 107.807,87 | 86,25% | R$ 138.509,71 | 110,81% | **1** |
| **6** | R$ 135.000 | R$ 154.763,22 | 114,64% | R$ 107.536,58 | 79,66% | R$ 133.031,37 | 98,54% | **1** |
| **7** | R$ 140.000 | R$ 138.455,24 | 98,90% | R$ 147.037,91 | 105,03% | R$ 130.084,28 | 92,92% | **1** |
| **8** | R$ 115.000 | R$ 143.037,81 | 124,38% | R$ 100.554,17 | 87,44% | R$ 182.060,86 | 158,31% | **2** |
| **9** | R$ 145.000 | R$ 138.266,45 | 95,36% | R$ 120.078,23 | 82,81% | R$ 141.016,08 | 97,25% | **0** |
| **10** | R$ 130.000 | R$ 153.568,35 | 118,13% | R$ 137.273,61 | 105,60% | R$ 72.508,56 | 55,78% | **2** |
| **11** | R$ 150.000 | R$ 163.031,57 | 108,69% | R$ 109.761,94 | 73,17% | R$ 170.179,90 | 113,45% | **2** |
| **12** | R$ 140.000 | R$ 109.093,78 | 77,92% | R$ 173.306,09 | 123,79% | R$ 154.246,93 | 110,18% | **2** |
| **13** | R$ 135.000 | R$ 137.255,86 | 101,67% | R$ 114.232,91 | 84,62% | R$ 148.180,33 | 109,76% | **2** |
| **14** | R$ 125.000 | R$ 170.761,75 | 136,61% | R$ 130.231,45 | 104,19% | R$ 110.216,99 | 88,17% | **2** |

*Nota: Nenhum vendedor conseguiu bater a meta em todos os 3 meses do trimestre. O vendedor 9 foi o único a não bater a meta em nenhum mês.*

---

### 2. Ranking de Vendedores por Equipe (Trimestre Q2/2026)

| Equipe | Posição | ID Vendedor | Faturamento Trimestre | Meta Trimestre | % Atingimento |
|---|:---:|:---:|:---:|:---:|:---:|
| **E-commerce Direto** | 1 | 8 | R$ 425.652,83 | R$ 345.000,00 | **123,38%** |
| | 2 | 13 | R$ 399.669,10 | R$ 405.000,00 | 98,68% |
| | 3 | 9 | R$ 399.360,76 | R$ 435.000,00 | 91,81% |
| **Centro-Oeste** | 1 | 4 | R$ 393.120,67 | R$ 360.000,00 | **109,20%** |
| | 2 | 11 | R$ 442.973,42 | R$ 450.000,00 | 98,44% |
| | 3 | 6 | R$ 395.331,17 | R$ 405.000,00 | 97,61% |
| | 4 | 5 | R$ 360.241,73 | R$ 375.000,00 | 96,06% |
| | 5 | 3 | R$ 415.465,10 | R$ 450.000,00 | 92,33% |
| **Norte/Nordeste** | 1 | 12 | R$ 436.646,79 | R$ 420.000,00 | **103,96%** |
| | 2 | 7 | R$ 415.577,43 | R$ 420.000,00 | 98,95% |
| | 3 | 2 | R$ 372.286,42 | R$ 390.000,00 | 95,46% |
| **Sul/Sudeste** | 1 | 14 | R$ 411.210,19 | R$ 375.000,00 | **109,66%** |
| | 2 | 1 | R$ 358.229,04 | R$ 330.000,00 | **108,55%** |
| | 3 | 10 | R$ 363.350,52 | R$ 390.000,00 | 93,17% |

---

### 3. Visão Consolidada por Equipe

| Equipe | Total Faturamento | Total Meta | % Atingimento | Situação |
|---|:---:|:---:|:---:|:---:|
| **Sul/Sudeste** | R$ 1.132.789,74 | R$ 1.095.000,00 | **103,45%** | Meta atingida |
| **E-commerce Direto** | R$ 1.224.682,69 | R$ 1.185.000,00 | **103,35%** | Meta atingida |
| **Norte/Nordeste** | R$ 1.224.510,65 | R$ 1.230.000,00 | **99,55%** | Próximo da meta |
| **Centro-Oeste** | R$ 2.007.132,09 | R$ 2.040.000,00 | **98,39%** | Próximo da meta |

---

## Principais Achados e Análise de Tendência

1. **Destaques Positivos Individuais:**
   - **Vendedor 8 (E-commerce Direto):** Foi o maior destaque individual do trimestre, atingindo **123,38%** da sua meta acumulada (faturamento de R$ 425,6k para uma meta de R$ 345k) e fechando Junho com impressionantes **158,31%** de atingimento.
   - **Vendedor 4 (Centro-Oeste) e Vendedor 1 (Sul/Sudeste):** Demonstraram ótima consistência, batendo a meta em 2 dos 3 meses e finalizando o trimestre acima de 108% da meta.

2. **Pontos de Atenção e Quedas Abruptas:**
   - **Vendedor 10 (Sul/Sudeste):** Apresentou uma queda considerável ao longo do trimestre. Após performar acima da meta em Abril (118,13%) e Maio (105,60%), despencou para **55,78%** em Junho (apenas R$ 72,5k faturados). Requer investigação imediata sobre licenças, faltas ou perda de grandes clientes.
   - **Vendedor 14 (Sul/Sudeste):** Embora tenha fechado o trimestre em 1º da sua equipe (109,66%), sua curva de tendência foi estritamente declinante: passou de 136,61% (Abril) para 104,19% (Maio) e fechou Junho abaixo da meta (88,17%).
   - **Vendedor 9 (E-commerce Direto):** Único colaborador da empresa que não atingiu a meta em nenhum dos três meses isoladamente (fechando o trimestre em 91,81%).

3. **Análise por Equipe:**
   - As equipes **Sul/Sudeste (103,45%)** e **E-commerce Direto (103,35%)** bateram a meta do trimestre.
   - Nenhuma equipe ficou em situação crítica (abaixo de 95%), porém a **Equipe Centro-Oeste**, apesar de representar o maior faturamento absoluto da empresa (mais de R$ 2,0 milhões), não atingiu a meta global (98,39%) por conta de metas individuais muito elevadas agrupadas no mesmo setor.

---

## Recomendação para a Diretoria Comercial

- **Ajuste de Comissionamento:** Recomenda-se bonificar os vendedores **8, 4, 1, 12 e 14** pelo atingimento trimestral, mas aplicar gatilhos de consistência mensal para evitar premiar vendedores com curvas em queda livre no último mês.
- **Plano de Ação para Vendedor 10:** Agendar reunião individual com o Vendedor 10 para entender a queda severa de produtividade em Junho antes de fechar os números de comissão.
- **Revisão das Metas da Equipe Centro-Oeste:** O time Centro-Oeste traz o maior volume de vendas em R$, mas a régua de metas do grupo está exigindo acima da capacidade média de entrega.

---

## Aprendizados Técnicos em SQL

- **Lógica Window Function (`LAG`):** O uso de `LAG() OVER (PARTITION BY id_vendedor ORDER BY mes_pedido)` provou ser essencial para rastrear variações percentuais em séries temporais sem depender de queries cruzadas complexas.
- **Ranks Particionados:** O uso de `RANK() OVER (PARTITION BY equipe ...)` permitiu criar uma régua justa de comparação contextualizada por regional/canal de venda.
- **Consolidação em CTEs:** Encadeamento de CTEs para calcular faturamento mensal, agregar no trimestre e em seguida aplicar as Window Functions manteve o código performático e limpo.

---

## Arquivos desta pasta

- `queries.sql` — arquivo único consolidando a criação da `VIEW` e todas as queries comentadas
- `README.md` — este documento de relatório
- `Dashboard_Demanda003.pbix` — dashboard interativo desenvolvido no Power BI
- `dashboard_print.png` — visualização/print do Dashboard Comercial Vintra