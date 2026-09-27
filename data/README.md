# Dataset

**Source:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle)

Real, anonymized orders from a Brazilian marketplace, September 2016 to October 2018. 7 CSV files were used from the original 9 (sellers and geolocation were added later for extended analysis; the sellers file is used in Queries 6 and 8).

## How to load this data

1. Download the dataset from the Kaggle link above (requires a free account).
2. Create a PostgreSQL database.
3. Import each CSV using a tool like DBeaver's Import Data wizard, or write your own load script.
4. Run `sql/01_schema_and_load.sql` for the order_reviews table setup and row-count verification.
5. Run `sql/02_data_cleaning.sql` to apply the documented cleaning fixes.
6. Run `sql/03_analysis_queries.sql` for the 8 analysis queries.

**Note:** the raw CSV files are not included in this repository (per portfolio best practice) — download them directly from Kaggle using the link above.
