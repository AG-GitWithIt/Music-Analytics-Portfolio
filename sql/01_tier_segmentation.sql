-- ====================================================================
-- Project: Music Catalog Valuation & AI Market Distortion
-- Author: AG-GitWithIt
-- File: 01_tier_segmentation.sql
-- Description: Categorizes digital storefront tracks into market performance
--              tiers using Common Table Expressions (CTEs) and conditional logic.
-- ====================================================================

WITH RawStorefrontData AS (
    SELECT 
        artist_id,
        artist_name,
        album_title,
        retail_price,
        review_count,
        total_streams,
        organic_stream_pct
    FROM digital_catalog_sales
),
CatalogTiers AS (
    SELECT 
        artist_name,
        album_title,
        retail_price,
        review_count,
        organic_stream_pct,
        CASE 
            WHEN review_count >= 1000 AND retail_price >= 10.50 THEN 'Anchor (Legacy Catalog)'
            WHEN review_count BETWEEN 50 AND 999 AND retail_price >= 8.99 THEN 'Contemporary Working Artist'
            WHEN review_count < 50 AND retail_price <= 8.99 THEN 'Transient / AI Sludge Risk'
            ELSE 'Uncategorized Mid-Tier'
        END AS market_tier
    FROM RawStorefrontData
)
SELECT 
    market_tier,
    COUNT(album_title) AS total_albums,
    ROUND(AVG(retail_price), 2) AS avg_retail_price,
    ROUND(AVG(review_count), 0) AS avg_review_count,
    ROUND(AVG(organic_stream_pct), 2) AS avg_organic_share
FROM CatalogTiers
GROUP BY market_tier
ORDER BY avg_retail_price DESC;
