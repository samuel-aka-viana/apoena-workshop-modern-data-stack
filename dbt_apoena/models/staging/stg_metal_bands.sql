{{ config(materialized='table') }}

select
    id as band_id,
    trim(name) band_name,
    trim(country) as country,
    trim(status) as status,
    {{ safe_cast_integer('formed_in') }} as formed_year,
    trim(genre) as genre,
    trim(theme) as theme,
    trim(active) as active_periods
from {{ source('metal_data','metal_bands') }}
where id is not null