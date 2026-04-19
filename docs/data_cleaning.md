# 🧹 Data Cleaning & Transformation

## 📌 Overview

This document explains the data cleaning and transformation steps performed in the project.

---

## 🔹 Data Source

The dataset was obtained from a MySQL database with restricted access permissions.

* Direct export was limited
* Data extraction was performed using Spoon (Pentaho Data Integration)

---

## 🔐 Data Access Note
The dataset used in this project was accessed from an external MySQL database.

Credentials and direct access details are not included in this repository for security and ethical reasons.

All transformations and queries required to reproduce the analysis are provided.

---

## 🔹 Challenges Faced

* Large dataset size (~375K+ rows)
* High number of columns (50+ unnecessary fields)
* Limited export permissions
* Performance issues in MySQL during processing

---

## 🔹 Cleaning Process (Spoon)

### Step 1: Column Reduction

* Removed 50–60 irrelevant columns
* Selected only key analytical fields:

  * Date
  * Airline
  * Origin & Destination
  * Delay metrics

---

### Step 2: Data Filtering

* Removed inconsistent or incomplete records
* Ensured required fields were retained

---

## 🔹 Transformation (MySQL)

### Step 3: Aggregation

* Converted detailed data into summarized format

```sql id="0cc3hs"
GROUP BY year, month, uniquecarrier, origin, dest
```

---

### Step 4: Optimization

* Reduced dataset size from ~375,000 rows to ~6,432 rows
* Improved performance significantly

---

## 🔹 Final Output

* Optimized fact table: `flight_summary_final`
* Analytical view: `vw_flight_analysis`

---

## 🚀 Key Result

The cleaned and transformed dataset enabled efficient analysis and seamless integration with Power BI.
