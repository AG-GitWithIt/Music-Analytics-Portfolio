-- ============================================================================
-- 1. DATABASE SETUP: Catalog Streaming Performance Logs
-- ============================================================================

DROP TABLE IF EXISTS catalog_stream_logs;

CREATE TABLE catalog_stream_logs (
    log_id INT PRIMARY KEY,
    artist_name VARCHAR(100),
    track_title VARCHAR(100),
    artist_type VARCHAR(50),
    release_month_number INT,
    monthly_streams INT,
    unique_monthly_listeners INT
);

INSERT INTO catalog_stream_logs 
    (log_id, artist_name, track_title, artist_type, release_month_number, monthly_streams, unique_monthly_listeners) 
VALUES
    (1,  'Apex Pop', 'Summer Hit', 'Mainstream', 1,  1000000, 850000),
    (2,  'Apex Pop', 'Summer Hit', 'Mainstream', 3,   450000, 400000),
    (3,  'Apex Pop', 'Summer Hit', 'Mainstream', 6,    80000,  75000),
    (4,  'Apex Pop', 'Summer Hit', 'Mainstream', 12,   25000,  24000),

    (5,  'Miles V.', 'Blue Mood',  'Indie / Jazz', 1,  150000,  95000),
    (6,  'Miles V.', 'Blue Mood',  'Indie / Jazz', 3,   95000,  60000),
    (7,  'Miles V.', 'Blue Mood',  'Indie / Jazz', 6,   62000,  38000),
    (8,  'Miles V.', 'Blue Mood',  'Indie / Jazz', 12,  55000,  32000);

-- ============================================================================
-- 2. ANALYTICAL QUERY: Catalog Decay & Retention Modeling
-- ============================================================================

WITH MonthlyRankings AS (
    SELECT 
        artist_name,
        track_title,
        artist_type,
        release_month_number,
        monthly_streams,
        unique_monthly_listeners,
        ROUND(CAST(monthly_streams AS REAL) / NULLIF(unique_monthly_listeners, 0), 2) AS repeat_stream_index,
        FIRST_VALUE(monthly_streams) OVER (
            PARTITION BY track_title 
            ORDER BY release_month_number ASC
        ) AS peak_month_streams
    FROM catalog_stream_logs
)
SELECT 
    artist_name,
    track_title,
    artist_type,
    release_month_number,
    monthly_streams,
    peak_month_streams,
    ROUND((CAST(monthly_streams AS REAL) / peak_month_streams) * 100, 2) AS retention_rate_pct,
    repeat_stream_index,
    CASE 
        WHEN release_month_number <= 3 THEN 'Initial Soar / Marketing Phase'
        WHEN (CAST(monthly_streams AS REAL) / peak_month_streams) >= 0.25 THEN 'High-Intent Baseline (Stable Asset)'
        ELSE 'High Decay / Algorithmic Fade'
    END AS catalog_health_status
FROM MonthlyRankings
ORDER BY artist_name, release_month_number;