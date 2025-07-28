{{ config(materialized='table') }}

select
    b.band_id,
    b.band_name,
    b.country,
    b.regiao,
    b.formed_year,
    b.era_formacao,
    b.categoria_idade,
    b.eh_ativa,

    count(distinct f.album_id) as total_albums,
    count(f.review_id) as total_reviews,

    round(avg(f.nota), 1) as nota_media,
    min(f.nota) as nota_minima,
    max(f.nota) as nota_maxima,
    round(max(f.nota) - min(f.nota), 1) as amplitude_notas,

    sum(f.eh_obra_prima) as albums_obra_prima,
    sum(f.eh_excelente) as albums_excelentes,
    sum(f.eh_muito_bom) as albums_muito_bons,
    sum(f.eh_bom) as albums_bons,
    sum(f.eh_ruim) as albums_ruins,

    round(
        case when count(f.review_id) = 0 then null else sum(f.eh_excelente) * 100.0 / count(f.review_id) end
    , 1) as pct_albums_excelentes,

    round(
        case when count(f.review_id) = 0 then null else sum(f.eh_muito_bom) * 100.0 / count(f.review_id) end
    , 1) as pct_albums_muito_bons,

    min(f.album_year) as primeiro_album,
    max(f.album_year) as ultimo_album,
    max(f.album_year) - min(f.album_year) as anos_atividade,

    case
        when max(f.album_year) - min(f.album_year) = 0 then count(distinct f.album_id)
        else count(distinct f.album_id)::double / nullif(max(f.album_year) - min(f.album_year),0)
    end as albums_por_ano,

    case
        when count(distinct f.album_id) >= 10 then 'Muito Prolífica (10+ albums)'
        when count(distinct f.album_id) >= 5  then 'Prolífica (5-9 albums)'
        when count(distinct f.album_id) >= 2  then 'Moderada (2-4 albums)'
        when count(distinct f.album_id) = 1  then 'Um álbum apenas'
        else 'Sem albums avaliados'
    end as nivel_produtividade,

    case
        when avg(f.nota) >= 85/100 then 'Qualidade Excepcional (85+)'
        when avg(f.nota) >= 75/100 then 'Alta Qualidade (75-84)'
        when avg(f.nota) >= 65/100 then 'Qualidade Média (65-74)'
        when avg(f.nota) >= 55/100 then 'Qualidade Baixa (55-64)'
        else 'Qualidade Muito Baixa (<55)'
    end as nivel_qualidade,

    case when count(distinct f.album_id) >= 5  then 1 else 0 end as eh_banda_produtiva,
    case when avg(f.nota) >= 75            then 1 else 0 end as eh_alta_qualidade,
    case when sum(f.eh_excelente) >= 2     then 1 else 0 end as tem_multiplos_excelentes

from {{ ref('dim_bands') }} b
left join {{ ref('fct_reviews') }} f on b.band_id = f.band_id
group by 1,2,3,4,5,6,7,8
having count(f.review_id) > 0
order by nota_media desc, total_albums desc
