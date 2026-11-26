
-- ============================================================
-- USE CASE 3: AI-POWERED CUSTOMER FEEDBACK ANALYSIS
-- DATABASE: API_DATA_ENGINEERING
-- SAMPLE DATA: 120 CUSTOMER FEEDBACK RECORDS
-- ============================================================

USE DATABASE API_DATA_ENGINEERING;

-- ============================================================
-- STEP 1: CREATE SCHEMAS
-- ============================================================

CREATE SCHEMA IF NOT EXISTS AI_RAW;
CREATE SCHEMA IF NOT EXISTS AI_ENRICHED;
CREATE SCHEMA IF NOT EXISTS AI_ANALYTICS;


-- ============================================================
-- STEP 2: CREATE RAW CUSTOMER FEEDBACK TABLE
-- ============================================================

CREATE OR REPLACE TABLE AI_RAW.CUSTOMER_FEEDBACK
(
    FEEDBACK_ID       NUMBER PRIMARY KEY,
    CUSTOMER_ID       NUMBER,
    CUSTOMER_NAME     VARCHAR(100),
    PRODUCT_NAME      VARCHAR(100),
    FEEDBACK_TEXT     VARCHAR(2000),
    SOURCE_CHANNEL    VARCHAR(50),
    CREATED_AT        TIMESTAMP_NTZ,
    IS_PROCESSED      BOOLEAN DEFAULT FALSE
);


-- ============================================================
-- STEP 3: GENERATE 120 SAMPLE CUSTOMER FEEDBACK RECORDS
-- 20 DIFFERENT FEEDBACK EXAMPLES X 6 BATCHES
-- ============================================================

INSERT INTO AI_RAW.CUSTOMER_FEEDBACK
(
    FEEDBACK_ID,
    CUSTOMER_ID,
    CUSTOMER_NAME,
    PRODUCT_NAME,
    FEEDBACK_TEXT,
    SOURCE_CHANNEL,
    CREATED_AT,
    IS_PROCESSED
)

WITH FEEDBACK_TEMPLATES AS
(
    SELECT *
    FROM VALUES

    (1, 'John Smith', 'Laptop',
     'Excellent product quality and very fast delivery. I am extremely satisfied.'),

    (2, 'Sarah Johnson', 'Smartphone',
     'The phone works well, but the delivery was very late.'),

    (3, 'David Brown', 'Headphones',
     'Very poor sound quality. I want to return this product and get a refund.'),

    (4, 'Emma Wilson', 'Smartwatch',
     'Customer support was excellent and resolved my problem quickly.'),

    (5, 'Michael Davis', 'Laptop',
     'The laptop is too expensive compared to similar products.'),

    (6, 'Olivia Taylor', 'Smartphone',
     'Amazing camera quality and excellent battery performance.'),

    (7, 'James Anderson', 'Headphones',
     'The product stopped working after two days. Very disappointed.'),

    (8, 'Sophia Thomas', 'Smartwatch',
     'Delivery was quick and packaging was very good.'),

    (9, 'William Jackson', 'Laptop',
     'The laptop performance is average. Nothing special.'),

    (10, 'Ava White', 'Smartphone',
     'I received the wrong product. The customer service team has not responded.'),

    (11, 'Robert Harris', 'Headphones',
     'Great product for the price. I would definitely recommend it.'),

    (12, 'Isabella Martin', 'Smartwatch',
     'The battery drains very quickly and the screen is not responsive.'),

    (13, 'Joseph Thompson', 'Laptop',
     'The product quality is good but delivery charges are too high.'),

    (14, 'Mia Garcia', 'Smartphone',
     'Fantastic experience. The product arrived earlier than expected.'),

    (15, 'Daniel Martinez', 'Headphones',
     'The headphones are comfortable but the sound quality could be better.'),

    (16, 'Charlotte Robinson', 'Smartwatch',
     'I am unhappy with the product. I would like to request a replacement.'),

    (17, 'Matthew Clark', 'Laptop',
     'Excellent performance and helpful technical support.'),

    (18, 'Amelia Rodriguez', 'Smartphone',
     'The product is okay, but the price is higher than expected.'),

    (19, 'Christopher Lewis', 'Headphones',
     'Customer service was rude and did not resolve my complaint.'),

    (20, 'Harper Lee', 'Smartwatch',
     'Very happy with my purchase. Good quality and fast delivery.')

    AS T(TEMPLATE_ID, CUSTOMER_NAME, PRODUCT_NAME, FEEDBACK_TEXT)
),

BATCHES AS
(
    SELECT SEQ4() AS BATCH_ID
    FROM TABLE(GENERATOR(ROWCOUNT => 6))
)

SELECT
    100000 + (B.BATCH_ID * 100) + T.TEMPLATE_ID,
    5000 + (B.BATCH_ID * 100) + T.TEMPLATE_ID,
    T.CUSTOMER_NAME,
    T.PRODUCT_NAME,
    T.FEEDBACK_TEXT,

    CASE
        WHEN MOD(T.TEMPLATE_ID + B.BATCH_ID, 3) = 0
            THEN 'WEBSITE'
        WHEN MOD(T.TEMPLATE_ID + B.BATCH_ID, 3) = 1
            THEN 'MOBILE_APP'
        ELSE 'EMAIL'
    END,

    DATEADD(
        DAY,
        -(B.BATCH_ID * 20 + T.TEMPLATE_ID),
        CURRENT_TIMESTAMP()
    ),

    FALSE

FROM FEEDBACK_TEMPLATES T
CROSS JOIN BATCHES B;


-- ============================================================
-- STEP 4: CREATE AI-ENRICHED CUSTOMER FEEDBACK TABLE
-- ============================================================

CREATE OR REPLACE TABLE AI_ENRICHED.CUSTOMER_FEEDBACK_AI
(
    FEEDBACK_ID          NUMBER,
    CUSTOMER_ID          NUMBER,
    CUSTOMER_NAME        VARCHAR(100),
    PRODUCT_NAME         VARCHAR(100),
    FEEDBACK_TEXT        VARCHAR(2000),

    SENTIMENT            VARCHAR(50),
    SENTIMENT_SCORE      FLOAT,

    FEEDBACK_CATEGORY    VARCHAR(100),
    EXTRACTED_INFORMATION VARIANT,
    AI_SUMMARY           VARCHAR(2000),

    AI_PROCESSED_AT      TIMESTAMP_NTZ,
    MODEL_NAME           VARCHAR(100)
);


-- ============================================================
-- STEP 5: CREATE ANALYTICS VIEW
-- ============================================================

CREATE OR REPLACE VIEW AI_ANALYTICS.V_CUSTOMER_FEEDBACK_SUMMARY AS

SELECT
    PRODUCT_NAME,
    FEEDBACK_CATEGORY,
    SENTIMENT,
    COUNT(*) AS FEEDBACK_COUNT,
    ROUND(AVG(SENTIMENT_SCORE), 3) AS AVG_SENTIMENT_SCORE

FROM AI_ENRICHED.CUSTOMER_FEEDBACK_AI

GROUP BY
    PRODUCT_NAME,
    FEEDBACK_CATEGORY,
    SENTIMENT;


-- ============================================================
-- STEP 6: VALIDATE RAW DATA
-- ============================================================

SELECT
    COUNT(*) AS TOTAL_RECORDS,
    COUNT(DISTINCT CUSTOMER_ID) AS UNIQUE_CUSTOMERS,
    COUNT(DISTINCT PRODUCT_NAME) AS TOTAL_PRODUCTS,
    COUNT(DISTINCT SOURCE_CHANNEL) AS SOURCE_CHANNELS,
    COUNT_IF(IS_PROCESSED = FALSE) AS PENDING_AI_RECORDS
FROM AI_RAW.CUSTOMER_FEEDBACK;


-- ============================================================
-- STEP 7: PREVIEW CUSTOMER FEEDBACK
-- ============================================================

SELECT *
FROM AI_RAW.CUSTOMER_FEEDBACK
ORDER BY FEEDBACK_ID
LIMIT 20;


-- ============================================================
-- STEP 8: VERIFY CREATED OBJECTS
-- ============================================================

SHOW TABLES IN SCHEMA AI_RAW;
SHOW TABLES IN SCHEMA AI_ENRICHED;
SHOW VIEWS IN SCHEMA AI_ANALYTICS;
