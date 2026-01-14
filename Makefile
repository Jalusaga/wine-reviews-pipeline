# =========================
# Configuration
# =========================

DBT_DIR=dbt
PYTHON=.venv/bin/python3


# =========================
# Targets
# =========================

.PHONY: help env load_raw dbt_run dbt_test dbt_docs all clean

help:
	@echo "Available commands:"
	@echo "  make env        Load environment variables"
	@echo "  make load_raw   Run Python EL (Kaggle → Snowflake RAW)"
	@echo "  make dbt_run    Run dbt transformations (STG + MART)"
	@echo "  make dbt_test   Run dbt tests"
	@echo "  make dbt_docs   Generate and serve dbt docs"
	@echo "  make all        Run full pipeline (ELT)"
	@echo "  make clean      Clean dbt artifacts"

# =========================
# .venv verification
# =========================

check-venv:
	@test -x .venv/bin/python || (echo "Virtualenv not found. Run: python3 -m venv .venv" && exit 1)
	@. .venv/bin/activate && python --version > /dev/null || (echo "Virtualenv not activated. Run: source .venv/bin/activate" && exit 1)

env:
	@echo "Loading environment variables from .env"
	@set -a && . ./.env && set +a

load_raw:
	@echo "Running RAW ingestion"
	@set -a && . ./.env && set +a && $(PYTHON) pipeline/load_raw.py

dbt_run:
	@echo "Running dbt models"
	@set -a && . ./.env && set +a && cd $(DBT_DIR) && dbt run

dbt_test:
	@echo "Running dbt tests"
	@set -a && . ./.env && set +a && cd $(DBT_DIR) && dbt test

dbt_docs:
	@echo "Generating and serving dbt docs"
	@set -a && . ./.env && set +a && cd $(DBT_DIR) && dbt docs generate && dbt docs serve

all: load_raw dbt_run dbt_test
	@echo "Pipeline completed successfully"

clean:
	@echo "Cleaning dbt artifacts"
	@cd $(DBT_DIR) && dbt clean
