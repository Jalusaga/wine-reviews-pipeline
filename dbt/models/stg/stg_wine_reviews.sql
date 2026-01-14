with raw as (
    select
        COUNTRY      as country,
        DESCRIPTION  as description,
        DESIGNATION  as designation,
        POINTS       as points_raw,
        PRICE        as price_raw,
        PROVINCE     as province,
        REGION_1     as region_1,
        REGION_2     as region_2,
        VARIETY      as variety,
        WINERY       as winery
    from {{ source('raw', 'WINE_REVIEWS_RAW') }}
),

typed as (
    select
        country,
        description,
        designation,
        try_to_number(points_raw) as points,
        try_to_decimal(price_raw, 10, 2) as price,
        province,
        region_1,
        region_2,
        variety,
        winery
    from raw
),

filtered as (
    -- Drop tiny number of rows missing country/province
    select *
    from typed
    where country is not null
      and province is not null
      and points is not null
),

median_price as (
    select
        percentile_cont(0.5) within group (order by price) as median_price
    from filtered
    where price is not null
      and price > 0
),

imputed as (
    select
        f.country,
        f.description,
        coalesce(f.designation, 'No designation') as designation,
        f.points,
        -- Median imputation for missing price (right-skew safe)
        coalesce(f.price, mp.median_price) as price,
        f.province,
        coalesce(f.region_1, 'Unknown region') as region_1,
        coalesce(f.region_2, 'No second region') as region_2,
        f.variety,
        f.winery
    from filtered f
    cross join median_price mp
),

deduped as (
    select
        *,
        row_number() over (
            partition by description, variety, winery, points
            order by price desc
        ) as rn
    from imputed
)

select
    country,
    description,
    designation,
    points,
    price,
    province,
    region_1,
    region_2,
    variety,
    winery
from deduped
where rn = 1
