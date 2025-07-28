{{ config(materialized='table') }}

with reviews as (
    select
        r.review_id,
        r.album_id,
        a.band_id,

        /* NOTA saneada 0-100 */
        {{ sanitize_score('r.score_album') }}::double as nota,

        a.album_title,
        a.album_year,
        a.numero_album_discografia,
        a.decada_lancamento,
        a.era_metal,
        a.fase_carreira_banda,
        a.eh_album_estreia,
        a.eh_era_dourada,

        a.band_name,
        a.country,
        a.regiao,
        a.era_formacao_banda,
        a.eh_ativa as banda_eh_ativa

    from {{ ref('stg_metal_reviews') }} r
    join {{ ref('dim_albums') }} a on r.album_id = a.album_id
    where r.score_album is not null
)

select
    *,
    /* Categorias derivadas a partir da nota saneada */
    case
        when nota >= 95/100 then 'Obra-Prima (95-100)'
        when nota >= 90/100 then 'Excelente (90-94)'
        when nota >= 80/100 then 'Muito Bom (80-89)'
        when nota >= 70/100 then 'Bom (70-79)'
        when nota >= 60/100 then 'Regular (60-69)'
        when nota >= 50/100 then 'Fraco (50-59)'
        else 'Ruim (0-49)'
    end as categoria_nota,

    case
        when nota >= 80/100 then 'Alta Qualidade'
        when nota >= 60/100 then 'Qualidade Média'
        else 'Baixa Qualidade'
    end as nivel_qualidade,

    case when nota >= 95/100 then 1 else 0 end as eh_obra_prima,
    case when nota >= 90/100 then 1 else 0 end as eh_excelente,
    case when nota >= 80/100 then 1 else 0 end as eh_muito_bom,
    case when nota >= 70/100 then 1 else 0 end as eh_bom,
    case when nota <  50/100 then 1 else 0 end as eh_ruim,

    nota - 70 as diferenca_nota_media,

    row_number() over (order by nota desc) as ranking_geral,
    row_number() over (partition by band_id order by nota desc) as ranking_na_banda,
    row_number() over (partition by country order by nota desc) as ranking_no_pais,
    row_number() over (partition by decada_lancamento order by nota desc) as ranking_na_decada

from reviews
order by nota desc
