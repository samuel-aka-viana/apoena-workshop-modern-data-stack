{{ config(materialized='table') }}

select
    band_id,
    band_name,
    country,
    status,
    formed_year,
    genre,
    theme,
    active_periods,

    case
        when lower(status) like '%active%' or lower(status) like '%ativo%' then 'Active'
        when lower(status) like '%split%' or lower(status) like '%disbanded%' then 'Split-up'
        when lower(status) like '%hiatus%' or lower(status) like '%hold%' then 'On Hold'
        else 'Unknown'
    end as current_status,

    case
        when genre is null or trim(genre) = '' then 'Desconhecido'
        else trim(genre)
    end as genre_clean,

    case
        when active_periods is null or trim(active_periods) = '' or active_periods = 'N/A' then false
        else true
    end as has_active_info,

    case
        when lower(status) like '%active%' then 1
        when lower(status) like '%split%' then 0
        else null
    end as is_probably_active

from {{ ref('stg_metal_bands') }}
where band_name is not null
