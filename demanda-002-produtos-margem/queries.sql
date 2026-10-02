-- ============================================================
-- Demanda 002 — Margem de Lucro e Priorização por Categoria (Jan-Mar 2026)
-- Critério: desconto aplicado tanto no faturamento quanto no lucro,
-- para manter as duas métricas na mesma base de cálculo.
-- ============================================================

-- 1) Faturamento por categoria
SELECT
    p.categoria,
    SUM(v.quantidade * v.preco_unitario * (1 - COALESCE(v.desconto_pct, 0))) AS faturamento
FROM vendas AS v
JOIN produtos AS p ON v.id_produto = p.id_produto
WHERE v.status_pedido = 'Concluído' AND v.data_pedido <= '2026-03-31'
GROUP BY p.categoria
ORDER BY faturamento DESC;


-- 2) Margem de lucro por categoria
SELECT
    p.categoria,
    SUM(v.quantidade * v.preco_unitario * (1 - COALESCE(v.desconto_pct, 0))) AS faturamento_real,
    ROUND(
        SUM(v.quantidade * (p.preco_venda * (1 - COALESCE(v.desconto_pct, 0)) - p.preco_custo))
        / SUM(v.quantidade * v.preco_unitario * (1 - COALESCE(v.desconto_pct, 0))) * 100
    , 2) AS margem_categoria
FROM vendas AS v
JOIN produtos AS p ON v.id_produto = p.id_produto
WHERE v.status_pedido = 'Concluído' AND v.data_pedido <= '2026-03-31'
GROUP BY p.categoria
ORDER BY margem_categoria DESC;


-- 3) Lucro bruto total por categoria
SELECT
    p.categoria,
    SUM(v.quantidade * (p.preco_venda * (1 - COALESCE(v.desconto_pct, 0)) - p.preco_custo)) AS lucro_bruto
FROM vendas AS v
JOIN produtos AS p ON v.id_produto = p.id_produto
WHERE v.status_pedido = 'Concluído' AND v.data_pedido <= '2026-03-31'
GROUP BY p.categoria
ORDER BY lucro_bruto DESC;


-- 4) Quantidade vendida por categoria
SELECT
    p.categoria,
    SUM(v.quantidade) AS qtd_vendidos
FROM vendas AS v
JOIN produtos AS p ON v.id_produto = p.id_produto
WHERE v.status_pedido = 'Concluído' AND v.data_pedido <= '2026-03-31'
GROUP BY p.categoria
ORDER BY qtd_vendidos DESC;


-- 5) Top 5 produtos mais lucrativos
SELECT
    p.nome_produto,
    SUM(v.quantidade * v.preco_unitario * (1 - COALESCE(v.desconto_pct, 0))) AS faturamento_prod,
    SUM(v.quantidade * (p.preco_venda * (1 - COALESCE(v.desconto_pct, 0)) - p.preco_custo)) AS lucro_prod
FROM vendas AS v
JOIN produtos AS p ON v.id_produto = p.id_produto
WHERE v.status_pedido = 'Concluído' AND v.data_pedido <= '2026-03-31'
GROUP BY p.nome_produto
ORDER BY lucro_prod DESC
LIMIT 5;


-- 6) Top 5 produtos menos vendidos (com estoque atual)
SELECT
    p.nome_produto,
    p.estoque_atual,
    SUM(v.quantidade) AS qtd_vendidos
FROM vendas AS v
JOIN produtos AS p ON v.id_produto = p.id_produto
WHERE v.status_pedido = 'Concluído' AND v.data_pedido <= '2026-03-31'
GROUP BY p.nome_produto, p.estoque_atual
ORDER BY qtd_vendidos ASC
LIMIT 5;
