-- ============================================================
-- Demanda 001 — Faturamento por Canal de Venda (Jan-Mar 2026)
-- Critérios aplicados:
--   - Apenas pedidos com status_pedido = 'Concluído'
--   - Pedidos com quantidade nula foram removidos na etapa de limpeza
--   - Duplicatas removidas comparando todas as colunas exceto id_pedido
-- ============================================================

-- 1) Faturamento total por canal de venda
SELECT
    canal_venda,
    SUM(quantidade * preco_unitario) AS faturamento
FROM vendas
WHERE status_pedido = 'Concluído'
  AND data_pedido <= '2026-03-31'
GROUP BY canal_venda
ORDER BY faturamento DESC;


-- 2) Ticket médio por canal de venda
SELECT
    canal_venda,
    ROUND(AVG(quantidade * preco_unitario), 2) AS ticket_medio
FROM vendas
WHERE status_pedido = 'Concluído'
  AND data_pedido <= '2026-03-31'
GROUP BY canal_venda
ORDER BY ticket_medio DESC;


-- 3) Quantidade de pedidos por canal de venda (trimestre completo)
SELECT
    canal_venda,
    COUNT(*) AS qtd_pedidos
FROM vendas
WHERE status_pedido = 'Concluído'
  AND data_pedido <= '2026-03-31'
GROUP BY canal_venda
ORDER BY qtd_pedidos DESC;


-- 4) Quantidade de pedidos por canal — recorte mensal
-- (usado para calcular a variação percentual mês a mês)

-- Janeiro
-- OBS: versão inicial usava "BETWEEN '2026-01-01' AND '2026-01-30'",
-- o que excluía o dia 31/01 por engano (janeiro tem 31 dias).
-- Esse foi o bug que causou a divergência entre a soma dos meses
-- e o total do trimestre — corrigido abaixo.
SELECT
    canal_venda,
    COUNT(*) AS qtd_pedidos
FROM vendas
WHERE status_pedido = 'Concluído'
  AND data_pedido BETWEEN '2026-01-01' AND '2026-01-31'
GROUP BY canal_venda
ORDER BY qtd_pedidos DESC;

-- Fevereiro
SELECT
    canal_venda,
    COUNT(*) AS qtd_pedidos
FROM vendas
WHERE status_pedido = 'Concluído'
  AND data_pedido BETWEEN '2026-02-01' AND '2026-02-28'
GROUP BY canal_venda
ORDER BY qtd_pedidos DESC;

-- Março
SELECT
    canal_venda,
    COUNT(*) AS qtd_pedidos
FROM vendas
WHERE status_pedido = 'Concluído'
  AND data_pedido BETWEEN '2026-03-01' AND '2026-03-31'
GROUP BY canal_venda
ORDER BY qtd_pedidos DESC;
