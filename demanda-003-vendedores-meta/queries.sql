-- =====================================================================
-- DEMANDA 003: PERFORMANCE DE VENDEDORES VS. META (Q2/2026)
-- =====================================================================

-- 1. Criação da view de vendas líquidas (base reutilizável)
create or replace view vw_vendas_liq as
select
  v.id_pedido,
  v.quantidade * v.preco_unitario *(1 - coalesce(v.desconto_pct, 0)) as valor_liquido,
  m.id_vendedor,
  m.meta_mensal,
  v.data_pedido,
  m.equipe,
  v.canal_venda
from vendas as v
join vendedores as m
on v.id_vendedor = m.id_vendedor
where v.status_pedido = 'Concluído';


-- Atualização de metas e validações de dados
-- Metas cadastradas eram de um ciclo anterior e mandou os valores atualizados
create table vendedores_bkp as select * from vendedores;

update vendedores as v
set meta_mensal = n.meta
from (values
    (1,110000),(2,130000),(3,150000),(4,120000),(5,125000),
    (6,135000),(7,140000),(8,115000),(9,145000),(10,130000),
    (11,150000),(12,140000),(13,135000),(14,125000)
) as n(id_vendedor, meta)
where v.id_vendedor = n.id_vendedor;

select count(*) from vw_vendas_liq;
select count(*) from vendas where status_pedido = 'Concluído';


-- 2. Performance mensal por vendedor (abr, mai e jun/2026)
-- Faturamento líquido do mês vs. meta_mensal e % de atingimento por mês
select
 id_vendedor,
 date_trunc('month', data_pedido) as mes_pedido,
 meta_mensal,
 round(sum(valor_liquido), 2) as fat_vendedor,
 round(sum(valor_liquido * 100 / meta_mensal), 2) as percent_meta_atingido
from vw_vendas_liq
where data_pedido between '2026-04-01' and '2026-06-30'
group by id_vendedor, date_trunc('month', data_pedido), meta_mensal
order by id_vendedor, mes_pedido;

-- Contagem de meses em que cada vendedor bateu a meta no trimestre
with fat_mensal as ( 
    select 
        id_vendedor,
        date_trunc('month', data_pedido) as mes_pedido,
        meta_mensal,
        round(sum(valor_liquido), 2) as fat_vendedor
    from vw_vendas_liq
    where data_pedido >= '2026-04-01'
    group by id_vendedor, date_trunc('month', data_pedido), meta_mensal
)
select 
    id_vendedor,
    count(case when fat_vendedor >= meta_mensal then 1 end) as metas_atingidas
from fat_mensal
group by id_vendedor
order by id_vendedor;


-- 3. Ranking e tendência
-- Ranking de vendedores dentro de cada equipe
with fat_vendedor as (
    select
        equipe,
        id_vendedor,
        meta_mensal * 3 as meta_trimestre,
        round(sum(valor_liquido), 2) as fat_trimestre
    from vw_vendas_liq
    where data_pedido >= '2026-04-01' and data_pedido < '2026-07-01'
    group by equipe, id_vendedor, meta_mensal
)
select
    equipe,
    id_vendedor,
    fat_trimestre,
    meta_trimestre,
    round(fat_trimestre * 100 / meta_trimestre, 2) as pct_atingimento,
    rank() over (partition by equipe order by fat_trimestre / meta_trimestre desc) as posicao_por_atingimento
from fat_vendedor
order by equipe, posicao_por_atingimento;

-- Evolução mês a mês de cada vendedor (tendência)
with fat_mensal as ( 
    select 
        id_vendedor,
        date_trunc('month', data_pedido) as mes_pedido,
        meta_mensal, -- Trazemos a meta para cá
        round(sum(valor_liquido), 2) as fat_vendedor
    from vw_vendas_liq
    where data_pedido between '2026-04-01' and '2026-07-01'
    group by id_vendedor, date_trunc('month', data_pedido), meta_mensal
),
evolucao as (
    select 
        id_vendedor,
        mes_pedido,
        meta_mensal,
        fat_vendedor as fat_atual,
        -- Percentual de atingimento da meta no mês atual (ex: 1.05 para 105%)
        round(fat_vendedor / nullif(meta_mensal, 0), 4) as pct_atingimento_atual,
        
        -- Pega o faturamento do mês anterior do MESMO vendedor:
        lag(fat_vendedor) over (
            partition by id_vendedor 
            order by mes_pedido
        ) as fat_anterior,

        -- Pega o percentual de atingimento do mês ANTERIOR para comparar:
        lag(round(fat_vendedor / nullif(meta_mensal, 0), 4)) over (
            partition by id_vendedor 
            order by mes_pedido
        ) as pct_atingimento_anterior
    from fat_mensal
)
select 
    id_vendedor,
    mes_pedido,
    fat_atual,
    meta_mensal,
    -- Exibe o % de atingimento formatado ou em decimal
    round(pct_atingimento_atual * 100, 2) as atingimento_atual_pct,
    fat_anterior,
    round(fat_atual - fat_anterior, 2) as diferenca_reais,
    
    -- Status baseado na variação do percentual de atingimento da meta:
    case 
        when pct_atingimento_anterior is null then 'Mês Inicial (Sem histórico)'
        when pct_atingimento_atual > pct_atingimento_anterior then 'Melhorando ' -- O % de atingimento subiu (ex: de 105% para 120%)
        when pct_atingimento_atual < pct_atingimento_anterior then 'Piorando '    -- O % de atingimento caiu (ex: de 105% para 101%, como no seu exemplo)
        else 'Estável '                                           -- Manteve exatamente o mesmo % de atingimento
    end as status_evolucao

from evolucao
order by id_vendedor, mes_pedido;


-- 4. Visão por equipe
select *,
    case
        when pct_atingimento_trimestre_equipe >= 110 then 'Destaque'
        when pct_atingimento_trimestre_equipe >= 100 then 'Meta atingida'
        when pct_atingimento_trimestre_equipe >= 95  then 'Próximo da meta'
        else 'Abaixo da meta'
    end as situacao
from (
  with fat_por_vendedor as (
    select 
        equipe,
        id_vendedor,
        DATE_TRUNC('month', data_pedido) AS mes_pedido,
        meta_mensal,
        sum(valor_liquido) as fat_vendedor
    from vw_vendas_liq
    where data_pedido between '2026-04-01' and '2026-07-01'
    group by equipe, id_vendedor, DATE_TRUNC('month', data_pedido), meta_mensal
),
consolidado_equipe as (  
    select 
        equipe,
        sum(fat_vendedor) as total_faturamento_trimestre,
        sum(meta_mensal) as total_meta_trimestre
    from fat_por_vendedor
    group by equipe
)
select 
    equipe,
    ROUND(total_faturamento_trimestre, 2) as total_faturamento,
    ROUND(total_meta_trimestre, 2) as total_meta,
    ROUND((total_faturamento_trimestre / nullif(total_meta_trimestre, 0)) * 100, 2) as pct_atingimento_trimestre_equipe
from consolidado_equipe

 ) as t
order by pct_atingimento_trimestre_equipe desc;

select * from vendedores;