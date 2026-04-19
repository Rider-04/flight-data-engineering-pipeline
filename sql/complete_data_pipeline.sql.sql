/* =========================================================
   ✈️ FLIGHT DATA ENGINEERING PROJECT - SQL SCRIPT
   Author: Parth Sharma

   Description:
   This script creates a complete data pipeline in MySQL:
   - Creates raw and dimension tables
   - Loads cleaned data (from Spoon / CSV)
   - Transforms data into aggregated format
   - Builds analytical views for reporting (Power BI)

   ========================================================= */


/* =========================================================
   🏗️ 1. DATABASE SETUP
   ========================================================= */

-- Create database
CREATE DATABASE Airline;

-- Use database
USE Airline;


/* =========================================================
   📥 2. FACT TABLE (RAW / CLEANED DATA)
   Source: Spoon (Pentaho Data Integration)
   ========================================================= */

-- This table contains cleaned flight-level data after ETL
CREATE TABLE flight_summary (
    FlightDate DATE,
    Year INT,
    Month INT,
    DayOfWeek INT,
    UniqueCarrier VARCHAR(10),
    Origin VARCHAR(10),
    Dest VARCHAR(10),
    TotalFlights INT,
    AvgDepDelay FLOAT,
    AvgArrDelay FLOAT,
    CancelledFlights INT,
    CarrierDelay FLOAT,
    WeatherDelay FLOAT,
    NASDelay FLOAT,
    LateAircraftDelay FLOAT
);


/* =========================================================
   📊 3. DIMENSION TABLES
   These tables provide descriptive attributes
   ========================================================= */

-- Airline dimension (maps carrier code → airline name)
CREATE TABLE dim_airline (
    AirlineCode VARCHAR(15),
    AirlineName TEXT
);

-- Load airline data from CSV
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\L_UNIQUE_CARRIERS.csv"
INTO TABLE dim_airline
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(AirlineCode, AirlineName);


-- Airport dimension (maps airport code → location details)
CREATE TABLE dim_airport (
    AirportCode VARCHAR(15),
    City VARCHAR(50),
    State VARCHAR(50),
    AirportName TEXT
);

-- Load airport data
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\L_AIRPORT.csv"
INTO TABLE dim_airport
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(AirportCode, City, State, AirportName);


-- Cancellation dimension (optional reference table)
CREATE TABLE dim_cancellation (
    CancellationCode VARCHAR(15),
    Description TEXT
);

-- Load cancellation codes
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\L_CANCELLATION.csv"
INTO TABLE dim_cancellation
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(CancellationCode, Description);


-- Month dimension (maps month number → month name)
CREATE TABLE dim_month (
    MonthCode INT,
    MonthName VARCHAR(20)
);

-- Load month data
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\L_MONTHS.csv"
INTO TABLE dim_month
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(MonthCode, MonthName);


/* =========================================================
   ⚙️ 4. DATA TRANSFORMATION (AGGREGATION)
   Goal: Reduce large dataset (~375K rows → ~6K rows)
   ========================================================= */

-- Create aggregated fact table for analysis
CREATE TABLE flight_summary_final AS
SELECT 
    year,
    MONTH(FlightDate) AS month,
    UniqueCarrier,
    Origin,
    Dest,

    -- Total number of flights per group
    COUNT(*) AS TotalFlights,

    -- Handle NULL values using IFNULL before aggregation
    AVG(IFNULL(WeatherDelay, 0)) AS AvgWeatherDelay,
    AVG(IFNULL(NASDelay, 0)) AS AvgNASDelay,
    AVG(IFNULL(LateAircraftDelay, 0)) AS AvgLateAircraftDelay

FROM flight_summary

-- Ensure valid date records
WHERE FlightDate IS NOT NULL

-- Aggregate by time + airline + route
GROUP BY 
    year,
    MONTH(FlightDate),
    UniqueCarrier,
    Origin,
    Dest;


/* =========================================================
   📊 5. ANALYTICAL VIEW (MAIN REPORTING LAYER)
   This view joins fact + dimensions for Power BI
   ========================================================= */

CREATE VIEW vw_flight_analysis AS
SELECT 
    f.year,
    f.month,
    m.MonthName,

    f.UniqueCarrier,
    a.AirlineName,

    f.origin,
    ap1.City AS OriginCity,
    ap1.State AS OriginState,
    ap1.AirportName AS OriginAirport,

    f.dest,
    ap2.City AS DestCity,
    ap2.State AS DestState,
    ap2.AirportName AS DestAirport,

    f.TotalFlights,
    f.AvgWeatherDelay,
    f.AvgNASDelay,
    f.AvgLateAircraftDelay

FROM flight_summary_final f

-- Join airline details
LEFT JOIN dim_airline a 
    ON f.UniqueCarrier = a.AirlineCode

-- Join origin airport
LEFT JOIN dim_airport ap1 
    ON f.origin = ap1.AirportCode

-- Join destination airport
LEFT JOIN dim_airport ap2 
    ON f.dest = ap2.AirportCode

-- Join month name
LEFT JOIN dim_month m 
    ON f.month = m.MonthCode;


/* =========================================================
   📈 6. KPI VIEW (AIRLINE LEVEL METRICS)
   ========================================================= */

CREATE VIEW vw_airline_kpi AS
SELECT 
    a.AirlineName,

    -- Total flights handled by airline
    SUM(f.TotalFlights) AS TotalFlights,

    -- Average delay metrics
    AVG(f.AvgWeatherDelay) AS AvgWeatherDelay,
    AVG(f.AvgNASDelay) AS AvgNASDelay

FROM flight_summary_final f

LEFT JOIN dim_airline a 
    ON f.UniqueCarrier = a.AirlineCode

GROUP BY a.AirlineName;


/* =========================================================
   🔍 7. VALIDATION & EXPLORATION QUERIES
   ========================================================= */

-- Check total rows in raw dataset
SELECT COUNT(*) FROM flight_summary;

-- Preview final analytical view
SELECT * FROM vw_flight_analysis;

-- Preview KPI view
SELECT * FROM vw_airline_kpi;

-- Inspect table structure (schema audit)
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'airline'
ORDER BY TABLE_NAME, ORDINAL_POSITION;