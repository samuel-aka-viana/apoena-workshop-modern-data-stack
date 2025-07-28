{{ config(materialized='table') }}

select
    band_id,
    band_name,
    country,
    formed_year,
    genre_clean as genre,
    current_status,

    case
        when country in ('United States', 'Canada') then 'América do Norte'
        when country in ('Brazil', 'Argentina', 'Chile', 'Mexico') then 'América Latina'
        when country in ('Germany', 'United Kingdom', 'Sweden', 'Norway', 'Finland', 'France', 'Italy') then 'Europa'
        when country in ('Japan', 'China', 'South Korea') then 'Ásia'
        else 'Outros'
    end as regiao,

    case
        when formed_year >= 2010 then 'Nova Geração (2010+)'
        when formed_year >= 2000 then 'Geração 2000s'
        when formed_year >= 1990 then 'Geração Anos 90'
        when formed_year >= 1980 then 'Geração Clássica (80s)'
        when formed_year is not null then 'Pioneiros (Pré-80s)'
        else 'Ano Desconhecido'
    end as era_formacao,

    case
        when formed_year is not null then 2024 - formed_year
        else null
    end as idade_banda,

    case
        when formed_year is null then 'Desconhecida'
        when 2024 - formed_year >= 30 then 'Veterana (30+ anos)'
        when 2024 - formed_year >= 15 then 'Experiente (15-29 anos)'
        when 2024 - formed_year >= 5 then 'Estabelecida (5-14 anos)'
        else 'Nova (0-4 anos)'
    end as categoria_idade,

    case when current_status = 'Active' then 1 else 0 end as eh_ativa,
    case when formed_year >= 2000 then 1 else 0 end as eh_banda_moderna,
    case when formed_year >= 1990 and formed_year <= 1999 then 1 else 0 end as eh_anos_90,
    case when country in ('United States', 'Germany', 'Sweden', 'United Kingdom') then 1 else 0 end as eh_pais_tradicional_metal


from {{ ref('int_metal_bands') }}
order by band_name