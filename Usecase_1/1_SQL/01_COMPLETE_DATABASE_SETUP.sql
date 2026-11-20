
-- =====================================================
-- PROJECT: SNOWFLAKE ETL - CUSTOMER DATA PLATFORM
-- ARCHITECTURE: MEDALLION (BRONZE / SILVER / GOLD)
-- PURPOSE: Reusable database and table creation
-- =====================================================


-- =====================================================
-- 1. CREATE DATABASE
-- =====================================================

CREATE DATABASE IF NOT EXISTS API_DATA_ENGINEERING;


-- =====================================================
-- 2. CREATE WAREHOUSE
-- =====================================================

CREATE WAREHOUSE IF NOT EXISTS API_PROJECT_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;


-- =====================================================
-- 3. CREATE SCHEMAS
-- =====================================================

CREATE SCHEMA IF NOT EXISTS API_DATA_ENGINEERING.BRONZE;

CREATE SCHEMA IF NOT EXISTS API_DATA_ENGINEERING.SILVER;

CREATE SCHEMA IF NOT EXISTS API_DATA_ENGINEERING.GOLD;


-- =====================================================
-- 4. BRONZE LAYER - RAW DATA
-- =====================================================

CREATE TABLE IF NOT EXISTS API_DATA_ENGINEERING.BRONZE.RAW_API_CUSTOMERS
(
    BATCH_ID        VARCHAR(100),
    SOURCE_NAME     VARCHAR(100),
    RAW_PAYLOAD     VARIANT,
    INGESTED_AT     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);


-- =====================================================
-- 5. SILVER LAYER - CLEANED DATA
-- =====================================================

CREATE TABLE IF NOT EXISTS API_DATA_ENGINEERING.SILVER.CUSTOMERS
(
    CUSTOMER_ID     VARCHAR(100),
    CUSTOMER_NAME   VARCHAR(255),
    EMAIL           VARCHAR(255),
    COUNTRY         VARCHAR(100),
    STATUS          VARCHAR(50),
    CITY            VARCHAR(150),
    POSTAL_CODE     VARCHAR(50),
    BATCH_ID        VARCHAR(100),
    PROCESSED_AT    TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);


CREATE TABLE IF NOT EXISTS API_DATA_ENGINEERING.SILVER.CUSTOMER_REJECTS
(
    BATCH_ID          VARCHAR(100),
    RAW_PAYLOAD       VARIANT,
    REJECTION_REASON  VARCHAR(1000),
    REJECTED_AT       TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);


-- =====================================================
-- 6. GOLD LAYER - BUSINESS DATA
-- =====================================================

CREATE TABLE IF NOT EXISTS API_DATA_ENGINEERING.GOLD.CUSTOMER_OVERVIEW
(
    COUNTRY              VARCHAR(100),
    TOTAL_CUSTOMERS      NUMBER(18,0),
    ACTIVE_CUSTOMERS     NUMBER(18,0),
    INACTIVE_CUSTOMERS   NUMBER(18,0),
    REFRESHED_AT         TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);


-- =====================================================
-- 7. AUDIT TABLE - PIPELINE EXECUTION
-- =====================================================

CREATE SCHEMA IF NOT EXISTS API_DATA_ENGINEERING.AUDIT;

CREATE TABLE IF NOT EXISTS API_DATA_ENGINEERING.AUDIT.ETL_EXECUTION_LOG
(
    RUN_ID          VARCHAR(100),
    PIPELINE_NAME   VARCHAR(255),
    LAYER_NAME      VARCHAR(50),
    STATUS          VARCHAR(50),
    RECORDS_READ    NUMBER(18,0),
    RECORDS_WRITTEN NUMBER(18,0),
    ERROR_MESSAGE   VARCHAR(5000),
    STARTED_AT      TIMESTAMP_NTZ,
    COMPLETED_AT   TIMESTAMP_NTZ,
    CREATED_AT      TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);


-- =====================================================
-- 8. SET DEFAULT WORKING CONTEXT
-- =====================================================

USE WAREHOUSE API_PROJECT_WH;

USE DATABASE API_DATA_ENGINEERING;

USE SCHEMA BRONZE;


-- =====================================================
-- 9. VERIFICATION
-- =====================================================

SHOW SCHEMAS IN DATABASE API_DATA_ENGINEERING;

SHOW TABLES IN SCHEMA API_DATA_ENGINEERING.BRONZE;

SHOW TABLES IN SCHEMA API_DATA_ENGINEERING.SILVER;

SHOW TABLES IN SCHEMA API_DATA_ENGINEERING.GOLD;

SHOW TABLES IN SCHEMA API_DATA_ENGINEERING.AUDIT;


-- =====================================================
-- END OF DATABASE SETUP
-- =====================================================

