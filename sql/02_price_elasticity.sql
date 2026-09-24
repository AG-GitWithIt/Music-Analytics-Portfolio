-- ====================================================================
-- Project: Music Catalog Valuation & AI Market Distortion
-- Author: AG-GitWithIt
-- File: 02_price_elasticity.sql
-- Description: Ranks catalog entries into price and review quartiles 
--              using window functions (NTILE) to isolate AI/ambient anomalies.
-- ====================================================================

WITH RankedCatalog AS (
    SELECT 
        artist_name,
        album_title,
        retail_price,
        review_count,
        NTILE(4) OVER (ORDER BY retail_price DESC) AS price_quartile,
        NTILE(4) OVER (ORDER BY review_count DESC) AS review_quartile
    FROM digital_catalog_sales
)
SELECT 
    price_quartile,
    review_quartile,
    COUNT(*) AS catalog_volume,
    CASE 
        WHEN price_quartile = 4 AND review_quartile = 4 THEN 'High AI/Sludge Exposure'
        WHEN price_quartile = 1 AND review_quartile = 1 THEN 'Core Premium Anchors'
        ELSE 'Standard Commercial Flow'
    END AS risk_segmentation
FROM RankedCatalog
GROUP BY price_quartile, review_quartile
ORDER BY price_quartile ASC, review_quartile ASC;
