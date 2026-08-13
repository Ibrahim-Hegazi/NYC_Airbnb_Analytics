# 🏙️ NYC Airbnb 2019 Analytics — Enterprise Data Warehouse & BI Solution

A fully automated, multi-tiered Business Intelligence pipeline built on Microsoft Fabric that ingests raw Airbnb listing data, applies a 42-check data quality framework, cleanses 12 actual errors, models a dimensional Star Schema, and delivers an interactive Power BI dashboard answering 10 SMART business questions about the NYC short-term rental market.

---

## 📌 Table of Contents

- [🔎 Project Overview](#-project-overview)
- [🎯 Business Problem & Objectives](#-business-problem--objectives)
- [🏗️ Architectural Governing Principles](#️-architectural-governing-principles)
- [📊 Data Overview](#-data-overview)
- [🚧 Key Technical Challenges & Roadblocks](#-key-technical-challenges--roadblocks)
- [💡 Proposed Solutions](#-proposed-solutions)
- [📈 System Architecture](#-system-architecture)
- [🔧 Features](#-features)
- [🧪 Pipeline Phases](#-pipeline-phases)
- [🧬 Data Flow Diagram](#-data-flow-diagram)
- [🗂 Directory Structure](#-directory-structure)
- [📦 Tech Stack](#-tech-stack)
- [🔍 Data Quality Framework](#-data-quality-framework)
- [📐 Dimensional Data Model](#-dimensional-data-model)
- [📊 SMART Questions](#-smart-questions)
- [🗓 Roadmap](#-roadmap)
- [🧾 License](#-license)
- [👨‍💻 Author](#-author)
- [📬 Future Improvements](#-future-improvements)
- [🙋‍♂️ Contributing](#-contributing)
- [📞 Contact](#-contact)

---

## 🔎 Project Overview

**NYC Airbnb 2019 Analytics** is an enterprise-grade data engineering and business intelligence solution that processes 48,895 short-term rental listings from the 2019 New York City Airbnb dataset. The pipeline follows a strict Medallion Architecture (Bronze → Silver → Gold) on Microsoft Fabric, implementing:

- ✅ **Schema Validation & Data Standardization**: 15 of 16 columns required type casting and column realignment
- ✅ **Comprehensive Data Profiling**: Pre-EDA and post-cleaning profiling with logical validation, statistical analysis, and outlier detection
- ✅ **42-Check Data Quality Framework**: 9 categories detecting 25 issues (12 actual errors, 8 business anomalies, 5 edge cases)
- ✅ **Data Cleansing**: 6 auto-fix operations applied during Silver layer transformation
- ✅ **Dimensional Modeling**: Star Schema with 1 fact table and 5 conformed dimensions
- ✅ **Semantic Layer**: 37 DAX measures and 4 calculated columns
- ✅ **Interactive Dashboard**: 7-page Power BI report answering 10 SMART business questions

---

## 🎯 Business Problem & Objectives

### The Business Problem

The New York City short-term rental market represents a complex ecosystem with significant implications for housing policy, tourism economics, and neighborhood dynamics. Traditional siloed operational systems fail to provide the multidimensional analytical visibility required to understand market concentration, pricing anomalies, and the shifting balance between individual hosts and commercial operators.

### Strategic Objectives

| Audience | Requirements |
|----------|-------------|
| **Executive Leadership & Policy Makers** | Macro-level market concentration metrics, borough-level supply distribution, systemic pricing trends |
| **Market Analysts & Real Estate Strategists** | Granular slice-and-dice capabilities to isolate high-demand neighborhoods, pinpoint pricing outliers, identify host concentration risks |
| **Operational Teams & Data Governance** | Daily operational intelligence on data quality metrics, pipeline health, listing completeness |

### Core Business Questions

- Which boroughs and neighborhoods command the highest average prices and supply concentration?
- Which room types generate the highest revenue potential and review velocity?
- How does pricing distribution shift across neighborhoods and host categories?
- Which hosts operate as commercial-scale operators, and what is their market share?
- How many listings are effectively inactive, and where are they concentrated?
- What is the overall market availability rate as a percentage of total listings?
- How has review activity trended over time, and which neighborhoods show growing demand?

---

## 🏗️ Architectural Governing Principles

The deployed framework adheres to strict layer isolation across the ingestion pipeline, ensuring fault tolerance, auditability, and complete execution lineage.

| Layer | Storage | Purpose | Key Operations |
|-------|---------|---------|----------------|
| **Bronze** | Lakehouse | Raw, immutable source copy | CSV-to-Delta conversion, schema-on-read |
| **Silver** | Lakehouse | Cleansed, validated data | 6 auto-fix operations, data standardization |
| **Gold** | Warehouse | Analytical dimensional model | Star Schema, surrogate keys, SCD strategy |

---

## 📊 Data Overview

### Executive Ingestion Summary

The enterprise pipeline ingests an exhaustive **48,895-record payload** originating from the Kaggle New York City Airbnb 2019 repository. Extracted from flat CSV files, this data represents high-fidelity short-term rental telemetry spanning all five NYC boroughs and 221 distinct neighborhoods.

### Data Dictionary

| Attribute | Logical Domain | Analytical Purpose |
|-----------|---------------|-------------------|
| id | Listing Core | Primary business key; 100% unique |
| name | Listing Core | Free-text listing title; cleaned for whitespace, newlines, null variations |
| host_id | Host Profile | Tracks host concentration and multi-listing behavior |
| host_name | Host Profile | Standardized for capitalization inconsistencies |
| neighbourhood_group | Geography | NYC borough classification (5 values) |
| neighbourhood | Geography | Granular neighborhood identifier (221 values) |
| latitude / longitude | Geography | Spatial vectors for geographic visualization |
| room_type | Listing Profile | Categorical classification (3 values) |
| price | Listing Core | Nightly rate; primary analytical target |
| minimum_nights | Listing Profile | Minimum stay requirement |
| number_of_reviews | Review Core | Cumulative review count |
| last_review | Review Core | Most recent review date (2011-2019) |
| reviews_per_month | Review Core | Review velocity metric |
| calculated_host_listings_count | Host Profile | Declared total listings per host |
| availability_365 | Listing Profile | Days available in calendar year (0-365) |

**Source:** Kaggle — New York City Airbnb Open Data | **Rows:** 48,895 | **Columns:** 16

---

## 🚧 Key Technical Challenges & Roadblocks

- **Schema Drift & Column Misalignment**: Raw CSV had data shifted across columns, creating 77 "neighborhood groups" and 86 "room types" instead of expected 5 and 3
- **Universal String Typing**: 15 of 16 columns ingested as strings regardless of logical type
- **Text Quality Issues**: 236 trailing whitespace instances, 168 embedded newlines, 287 whitespace contamination in `name`
- **High Cardinality Free Text**: 98% unique listing names requiring NLP-level handling
- **Severe Data Skewness**: Price skewness of 19.12, minimum_nights skewness of 21.83 — extreme outliers require business validation
- **Systematic Missing Data**: 20.56% of listings lack review data (MNAR pattern)
- **Inactive Listing Volume**: 35.85% of listings have zero availability but retain pricing data
- **No Ingestion Metadata**: Missing load timestamp column prevents SCD tracking and pipeline latency monitoring

---

## 💡 Proposed Solutions

- **Schema Validator & Cleaner/Normalizer**: Two-notebook approach to validate types, realign columns, and standardize formats before Bronze ingestion
- **42-Check DQ Framework**: Nine-category detection system covering Format, Validity, Completeness, Uniqueness, Consistency, Accuracy, Domain, Referential Integrity, and Timeliness
- **Issue Classification Matrix**: Three-tier classification (Actual Error, Business Anomaly, Edge Case) with stakeholder escalation framework
- **Six Auto-Fix Operations**: Whitespace trimming, newline removal, null standardization, capitalization correction, multi-space collapse
- **Medallion Architecture**: Bronze → Silver → Gold layer isolation ensuring auditability and lineage
- **Star Schema Design**: One fact table with five conformed dimensions for optimal analytical query performance
- **37 DAX Measures**: Core KPIs, pricing analysis, host analysis, review analysis, and time-based measures
- **7-Page Power BI Dashboard**: SMART question-driven visualizations with synchronized filtering

---

## 📈 System Architecture

<img width="1040" height="1739" alt="3_Project_Architecture" src="https://github.com/user-attachments/assets/64b679bc-67d3-49f0-be5c-b71a4104405a" />


---

## 🔧 Features

- ✅ 12-phase project lifecycle from environment setup to documentation
- ✅ Schema validation and column realignment for 16-column CSV
- ✅ Pre-EDA profiling with logical validation and statistical analysis
- ✅ Bronze layer ingestion with immutable Delta table preservation
- ✅ 42-check Data Quality framework across 9 categories
- ✅ 25-issue detection with 3-tier classification (Actual Error, Business Anomaly, Edge Case)
- ✅ 6 auto-fix cleansing operations in Silver layer
- ✅ Post-cleaning profiling with before/after comparison
- ✅ Star Schema dimensional modeling with 5 conformed dimensions
- ✅ 37 DAX measures and 4 calculated columns
- ✅ 7-page Power BI dashboard answering 10 SMART questions
- ✅ Comprehensive documentation with error catalog and stakeholder escalation matrix

---

## 🧪 Pipeline Phases

<details>
<summary>✅ Phase 1: Environment Setup</summary>

- 🔁 **Activities:**
  - Create Fabric Lakehouse and Warehouse
  - Establish Bronze, Silver, Gold schemas
  - Configure workspace permissions

- 🎯 **Purpose:**  
  Foundation for all subsequent phases.

- 📤 **Outputs:**  
  Lakehouse with Bronze/Silver schemas, Warehouse with Gold schema
</details>

<details>
<summary>✅ Phase 2: Raw Data Ingestion</summary>

- 🔁 **Activities:**
  - Manual upload of `AB_NYC_2019.csv` to Lakehouse Files section

- 🎯 **Purpose:**  
  Make raw source data available for validation and profiling.

- 📤 **Outputs:**  
  Raw CSV in Fabric OneLake
</details>

<details>
<summary>✅ Phase 3: Schema Validator & Cleaner/Normalizer (Notebooks 1-2)</summary>

- 🔁 **Activities:**
  - Schema inference and type validation
  - Column misalignment detection
  - Initial data type casting
  - Column realignment (77 → 5 boroughs, 86 → 3 room types)

- 🎯 **Purpose:**  
  Ensure structural conformity before Bronze ingestion.

- 📤 **Outputs:**  
  Validated schema, typed DataFrame
</details>

<details>
<summary>✅ Phase 4: Pre-EDA Data Profiling (Notebook 3)</summary>

- 🔁 **Activities:**
  - Column classification (IDENTIFIER, CATEGORICAL, COUNT, COORDINATE, etc.)
  - Statistical profiling (mean, median, std dev, skewness, kurtosis)
  - IQR outlier detection
  - Unique sample extraction
  - String checks (empty, whitespace, casing, length)

- 🎯 **Purpose:**  
  Understand data characteristics before DQ framework execution.

- 📤 **Outputs:**  
  Profiling report with 16-column analysis
</details>

<details>
<summary>✅ Phase 5: Bronze Ingestion (Notebook 4)</summary>

- 🔁 **Activities:**
  - Delta table creation from validated CSV
  - Schema-on-read preservation
  - Immutable source copy

- 🎯 **Purpose:**  
  Preserve raw data with complete audit trail.

- 📤 **Outputs:**  
  `Bronze.AB_NYC_2019` (48,895 rows, 16 columns)
</details>

<details>
<summary>✅ Phase 6: EDA & Data Quality Framework (Notebook 5)</summary>

- 🔁 **Activities:**
  - 42 checks across 9 DQ categories
  - Univariate/bivariate visualization (histograms, pairplots, heatmaps)
  - Issue classification and stakeholder escalation mapping

- 🎯 **Purpose:**  
  Systematic error detection before cleansing.

- 📤 **Outputs:**  
  25 detected issues, error catalog, classification matrix
</details>

<details>
<summary>✅ Phase 7: Data Cleaning & Silver Ingestion (Notebook 6)</summary>

- 🔁 **Activities:**
  - 6 auto-fix operations:
    - Whitespace trimming (236 rows)
    - Newline removal (168 rows)
    - Null standardization (1 row)
    - Capitalization correction (24 groups)
    - Multi-space collapse
    - Missing value flagging

- 🎯 **Purpose:**  
  Resolve actual errors for Silver layer.

- 📤 **Outputs:**  
  `Silver.AB_NYC_2019` (48,895 rows, cleansed)
</details>

<details>
<summary>✅ Phase 8: Post-Cleaning Profiling (Notebook 7)</summary>

- 🔁 **Activities:**
  - Validation profiling to verify fixes
  - Before/after comparison
  - Residual issue detection

- 🎯 **Purpose:**  
  Confirm data quality improvements.

- 📤 **Outputs:**  
  Post-clean profile, verification report
</details>

<details>
<summary>✅ Phase 9: Dimensional Data Modeling (Data Flow Gen2)</summary>

- 🔁 **Activities:**
  - Conceptual, logical, physical schema design (Draw.io, Oracle Data Modeler)
  - Star Schema implementation via Data Flow Gen2
  - Gold layer population in Warehouse

- 🎯 **Purpose:**  
  Create analytical data model for semantic layer.

- 📤 **Outputs:**  
  5 dimension tables, 1 fact table
</details>

<details>
<summary>✅ Phase 10: Semantic Model</summary>

- 🔁 **Activities:**
  - Power BI semantic model creation
  - Table relationships
  - 37 DAX measures
  - 4 calculated columns

- 🎯 **Purpose:**  
  Enable analytical querying and dashboard visualization.

- 📤 **Outputs:**  
  Semantic model with 6 tables, 37 measures
</details>

<details>
<summary>✅ Phase 11: Power BI Dashboard</summary>

- 🔁 **Activities:**
  - 7-page SMART dashboard development
  - Synchronized filtering
  - 10 core business questions answered

- 🎯 **Purpose:**  
  Deliver interactive analytics to stakeholders.

- 📤 **Outputs:**  
  Executive dashboard (7 pages)
</details>

<details>
<summary>✅ Phase 12: Documentation</summary>

- 🔁 **Activities:**
  - Technical architecture blueprint
  - Executive summary
  - Data dictionary
  - Error catalog
  - Stakeholder recommendations

- 🎯 **Purpose:**  
  Make project reproducible and production-ready.

- 📤 **Outputs:**  
  Complete documentation package
</details>

---

## 🧬 Data Flow Diagram

<img width="1008" height="296" alt="2_Project_Phases" src="https://github.com/user-attachments/assets/ae36067b-ec5f-48e6-9b1a-e9191534afeb" />

```
Raw CSV (48,895 rows, 16 columns)
        │
        ▼
Schema Validator (Notebook 1)
        │
        ▼
Cleaner/Normalizer (Notebook 2)
        │
        ▼
Pre-EDA Profiling (Notebook 3)
        │
        ▼
Bronze Ingestion (Notebook 4) → Bronze.AB_NYC_2019
        │
        ▼
EDA & DQ Framework (Notebook 5) → 25 Issues Detected
        │
        ▼
Data Cleaning (Notebook 6) → 6 Auto-Fixes Applied
        │
        ▼
Silver Ingestion → Silver.AB_NYC_2019
        │
        ▼
Post-Cleaning Profiling (Notebook 7)
        │
        ▼
Dimensional Modeling (Data Flow Gen2) → Gold Layer
        │
        ├── DimDate (3,196 rows)
        ├── DimHost (37,457 rows)
        ├── DimListing (48,895 rows)
        ├── DimNeighborhood (221 rows)
        ├── DimRoomType (3 rows)
        └── FactListing (48,895 rows)
        │
        ▼
Semantic Model (Power BI) → 37 DAX Measures
        │
        ▼
Dashboard (7 Pages, 10 SMART Questions)
```

---

## 🗂 Directory Structure

```
NYC_Airbnb_2019_Analytics/
│
├── README.md                          # Project overview and documentation
├── notebooks/                         # PySpark notebooks (7 total)
│   ├── Notebook1_Schema_Validator.ipynb
│   ├── Notebook2_Cleaner_Normalizer.ipynb
│   ├── Notebook3_Pre_EDA_Profiling.ipynb
│   ├── Notebook4_Bronze_Ingestion.ipynb
│   ├── Notebook5_EDA_DQ_Framework.ipynb
│   ├── Notebook6_Data_Cleaning_Silver.ipynb
│   └── Notebook7_Post_Cleaning_Profiling.ipynb
│
├── data/                              # Data assets
│   ├── raw/                           # Source CSV
│   │   └── AB_NYC_2019.csv
│   └── processed/                     # Exported profiling reports
│
├── docs/                              # Documentation
│   ├── architecture_diagram.png
│   ├── data_flow_diagram.png
│   ├── error_catalog.md
│   ├── data_dictionary.md
│   ├── dq_framework.md
│   ├── dimensional_model.md
│   └── stakeholder_escalation.md
│
├── dashboards/                        # Power BI files
│   └── NYC_Airbnb_2019_Analytics.pbix
│
└── sql/                               # SQL scripts for Gold layer
    ├── create_dim_tables.sql
    ├── create_fact_table.sql
    └── insert_gold_data.sql
```

---

## 📦 Tech Stack

| Category | Tool / Technology | Purpose |
|----------|-------------------|---------|
| Data Lakehouse | Microsoft Fabric | Unified storage and compute |
| Data Warehouse | Microsoft Fabric Warehouse | Gold layer storage |
| Ingestion | PySpark Notebooks (7) | Schema validation, profiling, DQ checks, cleansing |
| Data Quality | Python/PySpark | 42-check DQ framework |
| Profiling | PySpark, Matplotlib, Seaborn | Statistical profiling, visualizations |
| Data Modeling | Draw.io, Oracle SQL Developer Data Modeler | ERD design |
| ETL | Fabric Data Flow Gen2 | Dimension/fact loading |
| Visualization | Power BI | Semantic model, dashboard |
| Language | Python 3.10+ | All PySpark notebooks |
| Storage | Delta Lake (Bronze/Silver), Warehouse (Gold) | Medallion layers |

---

## 🔍 Data Quality Framework

### Framework Overview

| Category | Checks | Issues Detected |
|----------|--------|-----------------|
| 5.1 Format/Value Standardization | 8 | 5 |
| 5.2 Validity | 5 | 2 |
| 5.3 Completeness | 4 | 4 |
| 5.4 Uniqueness | 3 | 0 |
| 5.5 Consistency | 6 | 8 |
| 5.6 Accuracy | 4 | 6 |
| 5.7 Domain Validation | 4 | 1 |
| 5.8 Referential Integrity | 3 | 0 (N/A) |
| 5.9 Timeliness | 5 | 3 |
| **Total** | **42** | **25** |

### Issue Classification

| Classification | Count | Action |
|----------------|-------|--------|
| Actual Error | 12 | Auto-fix or flag for correction |
| Business Anomaly | 8 | Escalate to stakeholder |
| Edge Case | 5 | Accept as-is, document |

### Resolved Errors

| # | Column(s) | Fix Applied |
|---|-----------|-------------|
| 1 | name | `trim()` — 236 rows |
| 2 | name | Title case — 377 groups |
| 3 | host_name | Typo correction — 24 groups |
| 4 | name | `'.'` → null — 1 row |
| 5 | name | `\n` → space — 168 rows |
| 6 | name | Multi-space collapse — 3+ rows |

---

## 📐 Dimensional Data Model

### Star Schema
<img width="2752" height="1492" alt="6_Physical_Schema" src="https://github.com/user-attachments/assets/8b8db849-13c9-4a00-b5e1-a75fca8ed6fa" />


<img width="744" height="569" alt="7_Semantic_Model" src="https://github.com/user-attachments/assets/7dee46b6-f93a-483a-a0ec-4c02e9bee7dd" />


### Table Sizes

| Table | Rows | Role |
|-------|------|------|
| FactListing | 48,895 | Fact table |
| DimDate | 3,196 | Date dimension |
| DimHost | 37,457 | Host dimension |
| DimListing | 48,895 | Listing dimension |
| DimNeighborhood | 221 | Neighborhood dimension |
| DimRoomType | 3 | Room type dimension |

---

## 📊 SMART Questions

### Smart Question 1: What is the current state of the NYC Airbnb market in 2019?

**Measurable:** Total Listings (48,895), Average Price ($152.72), Total Hosts (37,457), Occupancy Rate (30.9%)

**Visuals:** Card KPIs, Clustered Bar (Listings by Borough), Donut (Room Type Distribution)

---

### Smart Question 2: How does pricing vary by room type and neighborhood, and where are the outliers?

**Measurable:** 674 distinct price points, 388 outliers (3σ above $873), 3 room types, 221 neighborhoods

**Visuals:** Clustered Bar (Avg Price by Room Type), Stacked Bar (Borough × Room Type), Treemap (Price Tier), Table (Top 10 Neighborhoods)

---

### Smart Question 3: Which neighborhoods offer the best balance of availability, price, and reviews?

**Measurable:** 221 neighborhoods with complete metrics, 17,533 zero-availability listings (35.85%)

**Visuals:** Map (Geographic distribution), Scatter (Price vs Reviews), Stacked Bar (Booking Potential by Borough)

---

### Smart Question 4: Who are the power hosts, and how is the market split between individuals and commercial operators?

**Measurable:** 37,457 hosts, 680 hosts with >106 listings (1.39%), max listings per host = 327

**Visuals:** Pie (Host Category), Donut (Single vs Multi Listing), Table (Top 10 Hosts), Scatter (Listings vs Price)

---

## 🗓 Roadmap

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Environment Setup | ✅ Done |
| 2 | Raw Data Ingestion | ✅ Done |
| 3 | Schema Validator & Cleaner/Normalizer | ✅ Done |
| 4 | Pre-EDA Data Profiling | ✅ Done |
| 5 | Bronze Ingestion | ✅ Done |
| 6 | EDA & Data Quality Framework | ✅ Done |
| 7 | Data Cleaning & Silver Ingestion | ✅ Done |
| 8 | Post-Cleaning Profiling | ✅ Done |
| 9 | Dimensional Data Modeling | ✅ Done |
| 10 | Semantic Model | ✅ Done |
| 11 | Power BI Dashboard | ✅ Done |
| 12 | Documentation | ✅ Done |

---

## 🧾 License

No license has been selected for this project yet.  
All rights reserved — you may not use, copy, modify, or distribute this code without explicit permission from the author.

---

## 👨‍💻 Author

**Data Engineer & BI Developer**  
*Microsoft Fabric • PySpark • Dimensional Modeling • Power BI*

---

## 📬 Future Improvements

- **Automated Orchestration**
  - Implement Fabric Pipelines for scheduled Bronze → Silver → Gold execution
  - Add retry logic and failure alerting

- **SCD Type 2 Implementation**
  - Add `ingestion_timestamp` and `effective_date` / `end_date` columns to track historical changes
  - Enable point-in-time analysis of listing attributes

- **Data Quality Monitoring**
  - Create Power BI data quality dashboard tracking DQ metrics over time
  - Implement automated DQ alerts for pipeline failures

- **Advanced Analytics**
  - Price prediction model using regression on listing features
  - Demand forecasting based on review velocity and seasonal patterns
  - Neighborhood clustering for market segmentation

- **API Integration**
  - Expose curated Gold layer via REST API for downstream applications
  - Implement role-based access control for internal users

- **Geospatial Enhancements**
  - Integrate NYC zoning data for regulatory compliance analysis
  - Add proximity analysis to transit hubs and tourist attractions

---

## 🙋‍♂️ Contributing

Contributions are welcome! Please open an issue first to discuss any proposed changes.

---

## 📞 Contact

For questions or support, please reach out via the project repository.
