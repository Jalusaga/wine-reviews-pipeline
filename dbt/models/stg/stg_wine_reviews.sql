select
  COUNTRY      as country,
  PROVINCE     as province,
  DESCRIPTION  as description,
  DESIGNATION  as designation,
  REGION_1     as region_1,
  REGION_2     as region_2,
  VARIETY      as variety,
  WINERY       as winery,
  POINTS       as points,
  PRICE        as price
from {{ source('raw', 'WINE_REVIEWS_RAW') }}
