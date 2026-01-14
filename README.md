# Wine Reviews ELT Pipeline (Kaggle → Snowflake → dbt)

This project implements an ELT pipeline using Python, Snowflake, and dbt to analyze wine pricing trends by grape variety. Raw data is ingested as an idempotent snapshot from Kaggle, then transformed in Snowflake using dbt. Data quality is enforced through schema tests and controlled imputation strategies. A mart layer aggregates price exposure and central tendency metrics to distinguish between popularity-driven and price-driven varieties. The design emphasizes reproducibility, transparency, and realistic data-engineering practices.

# Technologies used

- Python for Extract and Load (EL)

- dbt for Transform (T)

- Snowflake as the data warehouse

- Kaggle Wine Reviews dataset as the data source

---

The goal of this project is to demonstrate production-style data engineering practices such as idempotent loads, layered data modeling, and data quality enforcement.

# ARCHITECTURE OVERVIEW

```
Kaggle Dataset
↓
Python (kagglehub)
↓
Snowflake RAW (snapshot, idempotent)
↓
dbt STG (clean, typed, deduplicated)
↓
dbt MART (business metrics)
```

## DATASET

Source:

Kaggle: zynicide/wine-reviews

File used:

winemag-data_first150k.csv

### Dataset characteristics:

Snapshot dataset

No timestamps

No transactional or sales data

## PIPELINE LAYERS

### RAW

- Snapshot of the source CSV

- Loaded using Snowflake PUT + COPY INTO

- Idempotent via TRUNCATE + COPY

- No business logic applied

### STG

- Type casting and normalization

- Null handling and imputation

- Deduplication using a composite key

- Data quality rules enforced

### MART

- Aggregations by wine variety

Metrics include:

- review count

- average price

- median price

- price exposure (not revenue)

## PROJECT STRUCTURE

```
wine-reviews-pipeline/
│
├── pipeline/
│ └── load_raw.py Python EL: Kaggle → Snowflake RAW
│
├── dbt/
│ ├── dbt_project.ym
│ └── models/
│ ├── stg/
│ └── mart/
│
├── .env Snowflake credentials (not committed)
├── requirements.txt
├── .gitignore
└── README.md
```

# SETUP AND EXECUTION

Create a virtual environment

```python
python -m venv .venv
source .venv/bin/activate
```

Install dependencies

```python
pip install -r requirements.txt
```

Configure environment variables
Create a .env file in the project root with Snowflake credentials.

Load RAW data

```bash
python pipeline/load_raw.py
```

Run transformations

```bash
cd dbt
dbt run
dbt test
```

# KEY CONCEPTS DEMONSTRATED

- Idempotent snapshot ingestion

- Separation of concerns between EL and T

- dbt-based transformation modeling

- Data quality as code

- Reproducible analytics pipelines

# NOTES

- This project does not compute real revenue metrics.

- All metrics are derived from review data, not sales data.

- The pipeline is designed to be easily extensible with transactional datasets.

# AUTHOR

Built as a learning and portfolio project focused on real-world data engineering patterns.
