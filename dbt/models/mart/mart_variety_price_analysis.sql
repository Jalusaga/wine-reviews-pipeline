SELECT 
    variety,
    SUM(price) AS price_exposure,
    AVG(price) AS avg_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    COUNT(*) AS review_count,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) AS median_price
FROM 
    {{ ref('stg_wine_reviews') }}
GROUP BY 
    variety
HAVING 
    COUNT(*) >= 50