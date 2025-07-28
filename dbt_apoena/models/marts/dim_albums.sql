{{ config(materialized='table') }}

with albums_ranked as (
    select
        a.album_id,
        a.band_id,
        a.album_title,
        a.album_year,
        b.band_name,
        b.country,
        b.regiao,
        b.formed_year,
        b.era_formacao as era_formacao_banda,
        b.eh_ativa,

        row_number() over (partition by a.band_id order by a.album_year, a.album_id) as numero_album_discografia,

        count(*) over (partition by a.band_id) as total_albums_banda

    from {{ ref('stg_metal_albums') }} a
    join {{ ref('dim_bands') }} b on a.band_id = b.band_id
    where a.album_year is not null
)

select
    album_id,
    band_id,
    album_title,
    album_year,
    band_name,
    country,
    regiao,
    formed_year,
    era_formacao_banda,
    eh_ativa,
    numero_album_discografia,
    total_albums_banda,

    case
        when formed_year is not null then album_year - formed_year
        else null
    end as anos_depois_formacao,

    case
        when album_year >= 2020 then '2020s'
        when album_year >= 2010 then '2010s'
        when album_year >= 2000 then '2000s'
        when album_year >= 1990 then '1990s'
        when album_year >= 1980 then '1980s'
        else 'Pré-1980s'
    end as decada_lancamento,

    case
        when album_year >= 2010 then 'Era Moderna'
        when album_year >= 2000 then 'Era Digital'
        when album_year >= 1990 then 'Era Dourada do Death Metal'
        when album_year >= 1980 then 'Era Clássica do Metal'
        else 'Era Pioneira'
    end as era_metal,

    case
        when numero_album_discografia = 1 then 'Álbum de Estreia'
        when numero_album_discografia = 2 then 'Segundo Álbum'
        when numero_album_discografia <= 3 then 'Início de Carreira'
        when numero_album_discografia <= 5 then 'Meio de Carreira'
        else 'Carreira Madura'
    end as fase_carreira_banda,

    length(album_title),

    case when numero_album_discografia = 1 then 1 else 0 end as eh_album_estreia,
    case when album_year >= 2000 then 1 else 0 end as eh_seculo_21,
    case when album_year >= 1990 and album_year <= 1999 then 1 else 0 end as eh_era_dourada,
    case when numero_album_discografia <= 3 then 1 else 0 end as eh_inicio_carreira,
    case when total_albums_banda = 1 then 1 else 0 end as banda_um_album_apenas


from albums_ranked
order by band_name, numero_album_discografia