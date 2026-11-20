
-- ============================================================
-- USE CASE 2: SNOWFLAKE MEDALLION ARCHITECTURE
-- Project: Snowflake Data Engineering
-- Layers: Bronze | Silver | Gold
-- ============================================================

-- 1. DATABASE AND SCHEMA
CREATE DATABASE IF NOT EXISTS API_DATA_ENGINEERING;

CREATE SCHEMA IF NOT EXISTS
    API_DATA_ENGINEERING.BRONZE;

CREATE SCHEMA IF NOT EXISTS
    API_DATA_ENGINEERING.SILVER;

CREATE SCHEMA IF NOT EXISTS
    API_DATA_ENGINEERING.GOLD;

USE DATABASE API_DATA_ENGINEERING;
USE WAREHOUSE COMPUTE_WH;

-- ============================================================
-- 2. BRONZE LAYER - RAW DATA
-- ============================================================

CREATE TABLE IF NOT EXISTS BRONZE.RAW_JOKES (
    RECORD_ID       VARCHAR(100) DEFAULT UUID_STRING(),
    BATCH_ID        VARCHAR(100),
    SOURCE_SYSTEM   VARCHAR(100) DEFAULT 'JOKEAPI',
    RAW_DATA        VARIANT,
    INGESTED_AT     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    LOAD_DATE       DATE DEFAULT CURRENT_DATE(),
    STATUS          VARCHAR(30) DEFAULT 'NEW'
);

-- ============================================================
-- 3. SILVER LAYER - CLEANSED AND STANDARDIZED DATA
-- ============================================================

CREATE TABLE IF NOT EXISTS SILVER.CLEAN_JOKES (
    JOKE_ID          VARCHAR(100),
    CATEGORY         VARCHAR(100),
    JOKE_TYPE        VARCHAR(50),
    JOKE_TEXT        VARCHAR(5000),
    SETUP            VARCHAR(5000),
    DELIVERY         VARCHAR(5000),
    LANGUAGE         VARCHAR(20),
    SAFE_FLAG        BOOLEAN,
    SOURCE_SYSTEM    VARCHAR(100),
    BATCH_ID         VARCHAR(100),
    INGESTED_AT      TIMESTAMP_NTZ,
    PROCESSED_AT     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    RECORD_HASH      VARCHAR(64)
);

-- Data quality error records
CREATE TABLE IF NOT EXISTS SILVER.JOKE_DATA_QUALITY_ERRORS (
    ERROR_ID         VARCHAR(100) DEFAULT UUID_STRING(),
    RECORD_ID        VARCHAR(100),
    BATCH_ID         VARCHAR(100),
    ERROR_TYPE       VARCHAR(100),
    ERROR_MESSAGE    VARCHAR(2000),
    RAW_DATA         VARIANT,
    DETECTED_AT      TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================
-- 4. GOLD LAYER - BUSINESS READY DATA
-- ============================================================

-- Gold business-ready joke dataset
CREATE TABLE IF NOT EXISTS GOLD.DIM_JOKES (
    JOKE_ID          VARCHAR(100),
    CATEGORY         VARCHAR(100),
    JOKE_TYPE        VARCHAR(50),
    JOKE_TEXT        VARCHAR(5000),
    LANGUAGE         VARCHAR(20),
    SAFE_FLAG        BOOLEAN,
    SOURCE_SYSTEM    VARCHAR(100),
    FIRST_INGESTED_AT TIMESTAMP_NTZ,
    LAST_UPDATED_AT  TIMESTAMP_NTZ
);

-- Category-level business statistics
CREATE TABLE IF NOT EXISTS GOLD.AGG_JOKE_CATEGORY (
    CATEGORY         VARCHAR(100),
    TOTAL_JOKES      NUMBER(18,0),
    SINGLE_JOKES     NUMBER(18,0),
    TWOPART_JOKES    NUMBER(18,0),
    SAFE_JOKES       NUMBER(18,0),
    LAST_UPDATED_AT  TIMESTAMP_NTZ
);

-- Daily pipeline execution statistics
CREATE TABLE IF NOT EXISTS GOLD.AGG_DAILY_INGESTION (
    LOAD_DATE        DATE,
    TOTAL_INGESTED   NUMBER(18,0),
    TOTAL_PROCESSED  NUMBER(18,0),
    TOTAL_REJECTED   NUMBER(18,0),
    LAST_UPDATED_AT  TIMESTAMP_NTZ
);

-- ============================================================
-- 5. STREAMS - INCREMENTAL DATA CAPTURE
-- ============================================================

CREATE STREAM IF NOT EXISTS BRONZE.STREAM_RAW_JOKES
ON TABLE BRONZE.RAW_JOKES
APPEND_ONLY = TRUE;

-- ============================================================
-- 6. TASKS - PIPELINE ORCHESTRATION
-- Tasks will be enabled after their SQL procedures
-- have been implemented.
-- ============================================================

-- ============================================================
-- 7. DYNAMIC TABLE PLACEHOLDER
-- Dynamic Tables will be implemented separately after
-- validating the transformation logic and refresh strategy.
-- ============================================================

-- ============================================================
-- 8. ENVIRONMENT VALIDATION
-- ============================================================

SHOW SCHEMAS IN DATABASE API_DATA_ENGINEERING;

SHOW TABLES IN SCHEMA API_DATA_ENGINEERING.BRONZE;

SHOW TABLES IN SCHEMA API_DATA_ENGINEERING.SILVER;

SHOW TABLES IN SCHEMA API_DATA_ENGINEERING.GOLD;

SHOW STREAMS IN SCHEMA API_DATA_ENGINEERING.BRONZE;

-- ============================================================
-- END OF DATABASE STRUCTURE SETUP
-- ============================================================
