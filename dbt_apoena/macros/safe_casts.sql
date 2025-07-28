{% macro safe_cast_integer(column) %}
    {{ column }}::integer
{% endmacro %}

{% macro safe_cast_decimal(column) %}
    {{ column }}::decimal
{% endmacro %}

{% macro sanitize_score(expr, min_val=0, max_val=100) -%}
    greatest({{ min_val }}, least({{ expr }}, {{ max_val }}))
{%- endmacro %}