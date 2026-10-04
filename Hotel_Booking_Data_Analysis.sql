-- =====================================================
-- HOTEL BOOKING DATA ANALYSIS | MYSQL
-- =====================================================

-- Dataset: 5,000 hotel booking records
-- Database: hotel_analysis
-- Table: hotel_bookings
-- Tools: MySQL, SQL
-- Analysis: Bookings, Revenue, Cancellations,
--           Market Segments, Hotels, Countries,
--           Monthly Trends and Revenue Performance




-- =====================================================
-- PROJECT OBJECTIVE
-- =====================================================
-- Analyze hotel booking data to understand booking
-- patterns, cancellations, revenue performance,
-- customer segments, country performance, and
-- monthly trends using SQL.



-- =====================================================
-- DATA VALIDATION
-- =====================================================

-- Check total number of records
SELECT COUNT(*) AS total_records
FROM hotel_bookings;

-- Check duplicate booking IDs
SELECT booking_id, COUNT(*) AS record_count
FROM hotel_bookings
GROUP BY booking_id
HAVING COUNT(*) > 1;

-- Check available booking statuses
SELECT DISTINCT booking_status
FROM hotel_bookings;

-- Check available hotel types
SELECT DISTINCT hotel
FROM hotel_bookings;


-- =====================================================
-- 1. BOOKING OVERVIEW
-- =====================================================

-- Total bookings by hotel
SELECT
    hotel,
    COUNT(*) AS total_bookings
FROM hotel_bookings
GROUP BY hotel
ORDER BY total_bookings DESC;

-- Booking status by hotel
SELECT
    hotel,
    booking_status,
    COUNT(*) AS total_bookings
FROM hotel_bookings
GROUP BY hotel, booking_status
ORDER BY hotel, total_bookings DESC;


-- =====================================================
-- 2. CANCELLATION ANALYSIS
-- =====================================================

-- Overall cancellation rate by hotel
SELECT
    hotel,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN booking_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_bookings,
    ROUND(
        SUM(CASE WHEN booking_status = 'Cancelled' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS cancellation_rate
FROM hotel_bookings
GROUP BY hotel
ORDER BY cancellation_rate DESC;


-- =====================================================
-- 3. REVENUE ANALYSIS
-- =====================================================

-- Total booking value by hotel
SELECT
    hotel,
    ROUND(SUM(nights * adr), 2) AS total_booking_value
FROM hotel_bookings
GROUP BY hotel
ORDER BY total_booking_value DESC;

-- Realized revenue from completed stays
SELECT
    hotel,
    ROUND(SUM(nights * adr), 2) AS realized_revenue
FROM hotel_bookings
WHERE booking_status = 'Checked-Out'
GROUP BY hotel
ORDER BY realized_revenue DESC;



-- =====================================================
-- 4. MARKET SEGMENT ANALYSIS
-- =====================================================

-- Bookings by market segment
SELECT
    market_segment,
    COUNT(*) AS total_bookings
FROM hotel_bookings
GROUP BY market_segment
ORDER BY total_bookings DESC;

-- Realized revenue by market segment
SELECT
    market_segment,
    ROUND(SUM(nights * adr), 2) AS realized_revenue
FROM hotel_bookings
WHERE booking_status = 'Checked-Out'
GROUP BY market_segment
ORDER BY realized_revenue DESC;


-- =====================================================
-- 5. COUNTRY ANALYSIS
-- =====================================================

-- Bookings by country
SELECT
    country,
    COUNT(*) AS total_bookings
FROM hotel_bookings
GROUP BY country
ORDER BY total_bookings DESC;

-- Realized revenue by country
SELECT
    country,
    ROUND(SUM(nights * adr), 2) AS realized_revenue
FROM hotel_bookings
WHERE booking_status = 'Checked-Out'
GROUP BY country
ORDER BY realized_revenue DESC;


-- =====================================================
-- 6. MONTHLY REVENUE ANALYSIS
-- =====================================================

-- Monthly realized revenue
SELECT
    YEAR(arrival_date) AS arrival_year,
    MONTH(arrival_date) AS arrival_month,
    ROUND(SUM(nights * adr), 2) AS realized_revenue
FROM hotel_bookings
WHERE booking_status = 'Checked-Out'
GROUP BY YEAR(arrival_date), MONTH(arrival_date)
ORDER BY arrival_year, arrival_month;


-- =====================================================
-- 7. HOTEL PERFORMANCE ANALYSIS
-- =====================================================

-- Average ADR and average length of stay by hotel
SELECT
    hotel,
    ROUND(AVG(adr), 2) AS average_adr,
    ROUND(AVG(nights), 2) AS average_length_of_stay
FROM hotel_bookings
WHERE booking_status = 'Checked-Out'
GROUP BY hotel
ORDER BY average_adr DESC;


-- =====================================================
-- 8. ROOM TYPE ANALYSIS
-- =====================================================

-- Bookings by room type
SELECT
    room_type,
    COUNT(*) AS total_bookings
FROM hotel_bookings
GROUP BY room_type
ORDER BY total_bookings DESC;

-- Realized revenue by room type
SELECT
    room_type,
    ROUND(SUM(nights * adr), 2) AS realized_revenue
FROM hotel_bookings
WHERE booking_status = 'Checked-Out'
GROUP BY room_type
ORDER BY realized_revenue DESC;


-- =====================================================
-- 9. MEAL ANALYSIS
-- =====================================================

-- Bookings by meal type
SELECT
    meal,
    COUNT(*) AS total_bookings
FROM hotel_bookings
GROUP BY meal
ORDER BY total_bookings DESC;

-- Realized revenue by meal type
SELECT
    meal,
    ROUND(SUM(nights * adr), 2) AS realized_revenue
FROM hotel_bookings
WHERE booking_status = 'Checked-Out'
GROUP BY meal
ORDER BY realized_revenue DESC;


-- =====================================================
-- 10. OVERALL PROJECT KPIs
-- =====================================================

-- Total bookings
SELECT COUNT(*) AS total_bookings
FROM hotel_bookings;

-- Total booking value
SELECT
    ROUND(SUM(nights * adr), 2) AS total_booking_value
FROM hotel_bookings;

-- Realized revenue
SELECT
    ROUND(SUM(nights * adr), 2) AS realized_revenue
FROM hotel_bookings
WHERE booking_status = 'Checked-Out';

-- Overall revenue realization rate
SELECT
    ROUND(
        SUM(CASE WHEN booking_status = 'Checked-Out'
                 THEN nights * adr ELSE 0 END)
        * 100.0 / SUM(nights * adr), 2
    ) AS revenue_realization_rate;
    
    
    -- =====================================================
-- 11. ADVANCED ANALYSIS
-- =====================================================

-- Revenue by hotel and market segment
SELECT
    hotel,
    market_segment,
    ROUND(SUM(nights * adr), 2) AS realized_revenue
FROM hotel_bookings
WHERE booking_status = 'Checked-Out'
GROUP BY hotel, market_segment
ORDER BY hotel, realized_revenue DESC;


-- =====================================================
-- 12. TOP REVENUE SEGMENT BY HOTEL
-- =====================================================

WITH segment_revenue AS (
    SELECT
        hotel,
        market_segment,
        SUM(nights * adr) AS realized_revenue
    FROM hotel_bookings
    WHERE booking_status = 'Checked-Out'
    GROUP BY hotel, market_segment
),
ranked_segments AS (
    SELECT
        hotel,
        market_segment,
        realized_revenue,
        RANK() OVER (
            PARTITION BY hotel
            ORDER BY realized_revenue DESC
        ) AS revenue_rank
    FROM segment_revenue
)
SELECT
    hotel,
    market_segment,
    ROUND(realized_revenue, 2) AS realized_revenue
FROM ranked_segments
WHERE revenue_rank = 1;


-- =====================================================
-- 13. HIGHEST CANCELLATION SEGMENT BY HOTEL
-- =====================================================

WITH segment_cancellations AS (
    SELECT
        hotel,
        market_segment,
        COUNT(*) AS total_bookings,
        SUM(CASE
            WHEN booking_status = 'Cancelled' THEN 1
            ELSE 0
        END) AS cancelled_bookings
    FROM hotel_bookings
    GROUP BY hotel, market_segment
),
ranked_cancellations AS (
    SELECT
        hotel,
        market_segment,
        total_bookings,
        cancelled_bookings,
        ROUND(
            cancelled_bookings * 100.0 / total_bookings, 2
        ) AS cancellation_rate,
        RANK() OVER (
            PARTITION BY hotel
            ORDER BY cancelled_bookings * 100.0 / total_bookings DESC
        ) AS cancellation_rank
    FROM segment_cancellations
)
SELECT
    hotel,
    market_segment,
    total_bookings,
    cancelled_bookings,
    cancellation_rate
FROM ranked_cancellations
WHERE cancellation_rank = 1;


-- =====================================================
-- 14. FINAL HOTEL PERFORMANCE SUMMARY
-- =====================================================

SELECT
    hotel,
    COUNT(*) AS total_bookings,
    SUM(CASE
        WHEN booking_status = 'Cancelled' THEN 1
        ELSE 0
    END) AS cancelled_bookings,
    ROUND(
        SUM(CASE
            WHEN booking_status = 'Cancelled' THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*), 2
    ) AS cancellation_rate,
    ROUND(
        SUM(CASE
            WHEN booking_status = 'Checked-Out'
            THEN nights * adr
            ELSE 0
        END), 2
    ) AS realized_revenue
FROM hotel_bookings
GROUP BY hotel
ORDER BY realized_revenue DESC;
