# Notebooks

This directory contains the PySpark ETL scripts used in the Retail Data Warehouse project.

## Files

### pyspark_etl.py
Performs the ETL pipeline:
- Reads raw retail transaction data
- Cleans and validates records
- Handles missing and duplicate values
- Transforms data into an analytics-ready format
- Loads processed data into the warehouse layer

## Technologies Used
- PySpark
- SQL
- Delta Lake
- Databricks

## Output
The transformed data is stored in Delta tables and used for reporting and dashboard creation.
