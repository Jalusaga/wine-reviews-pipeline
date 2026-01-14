SELECT
    *
FROM 
    {{ ref('mart_variety_price_analysis') }}
WHERE
    review_count < 50