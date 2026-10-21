# Vintra Analytics — Simulação de Rotina de Analista de Dados Jr.

## 🎯 Sobre este projeto

Este repositório documenta uma simulação prática da rotina de um **Analista de Dados Jr.**, criada para desenvolver e **demonstrar** minhas habilidades técnicas e analíticas uma vez que ainda não possuo experiência efetiva na área.

A simulação funciona como uma relação **Gestor–Analista**, na qual eu assumo o papel de Analista e recebo demandas diárias de dados de uma IA atuando como Gestor de Analytics. As demandas incluem desde limpeza e tratamento de dados até construção de queries SQL, geração de relatórios, construção de dashboards e apresentação de recomendações de negócio.

**Importante:** todos os dados, a empresa ("Vintra Comércio Eletrônico") e as demandas são **fictícios**, criados especificamente para fins de treino e portfólio. Nenhuma informação real de empresa, cliente ou vendedor está envolvida.

## 🧭 Por que este formato?

Optei por simular esse ciclo completo e não só escrever queries soltas. Dessa forma potencializo capacidades essenciais de um analista júnior como:

- Tomar decisões defensáveis diante de dados sujos ou incompletos
- Validar e reconciliar os próprios números antes de entregar
- Traduzir resultado técnico em recomendação de negócio
- Saber quando pedir mais contexto em vez de assumir uma resposta
- Desenvolver pensamentos analíticos e lógicos em prol da empresa

Este repositório documenta não só os resultados, mas o **processo de raciocínio** por trás de cada entrega — incluindo erros cometidos e como foram corrigidos.

## 🗂️ Cenário

**Empresa:** Vintra Comércio Eletrônico (fictícia) — e-commerce de eletrônicos, casa inteligente, informática, acessórios mobile e games, vendendo por site próprio, marketplaces, loja física e app.

**Banco de dados:** Tabelas relacionadas (Vendas, Produtos, Clientes, Vendedores), modeladas em PostgreSQL, com ~6.500 pedidos no período de jan–jun/2026. A base foi propositalmente construída com inconsistências reais de empresa para simular o trabalho de limpeza que antecede qualquer análise.

**Ferramentas utilizadas:** PostgreSQL (SQL), Power BI (Dashboards interativos), Excel/planilhas para exploração inicial, e raciocínio analítico orientado por um gestor simulado.

## 📁 Estrutura do repositório

├── README.md                              ← este arquivo
├── /demanda-001-vendas-canal              ← limpeza de dados + faturamento por canal
│   ├── README.md
│   └── queries.sql
├── /demanda-002-produtos-margem           ← margem de lucro e priorização por categoria
│   ├── README.md
│   └── queries.sql
├── /demanda-003-vendedores-meta           ← performance de vendedores vs. meta (Q2/2026)
│   ├── README.md
│   ├── queries.sql
│   ├── Dashboard_Demanda003.pbix
│   └── dashboard_print.png
└── ...

Cada pasta de demanda contém seu próprio README, explicando o contexto do pedido, as decisões de tratamento de dado tomadas, os resultados, os aprendizados e os arquivos técnicos da entrega.

## 📌 Demandas concluídas

| # | Demanda | Foco | Status |
|---|---|---|---|
| 001 | Limpeza de base + Faturamento por Canal de Venda | Tratamento de dados, agregação SQL | ✅ Concluída |
| 002 | Margem de Lucro e Priorização por Categoria | JOIN, margem vs. markup, priorização de negócio | ✅ Concluída |
| 003 | Performance de Vendedores vs. Meta (Q2/2026) | Window functions (LAG, RANK), metas, views reutilizáveis e dashboard em Power BI | ✅ Concluída |

*(lista será atualizada a cada nova demanda)*

## 🛠️ Stack técnica

- SQL (PostgreSQL)
- Power BI (Modelagem DAX e visualização de dados)
- Tratamento e modelagem de dados — Python (Google Colab)
- Análise exploratória e reconciliação de métricas
- Comunicação de resultados para áreas de negócio (Comercial, Marketing)

---

*Projeto pessoal de estudo e portfólio. Dados sintéticos gerados especificamente para esta simulação.*