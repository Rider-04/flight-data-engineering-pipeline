# 🏗️ Data Architecture

## 📌 Pipeline Design

The project follows a hybrid ETL/ELT approach:

1. Extraction using Spoon
2. Transformation using MySQL
3. Visualization using Power BI

---

## 🔹 Data Flow

* Raw Data → Extracted via Spoon
* Cleaned Dataset → Loaded into MySQL
* Aggregated Table → `flight_summary_final`
* Analytical Views → Power BI

---

## 🔹 Design Decisions

* Column reduction to improve performance
* Aggregation to reduce dataset size
* Use of views for reusable analytics layer

---

## 🚀 Outcome

Efficient and scalable pipeline suitable for BI tools.
