# -SQL-Business-Analytics-Project
## Overview
This project demonstrates business analytics using SQL on a small relational sales dataset. The goal is to answer practical business questions using joins, aggregations, CTEs, and window functions.

## Data Model
Tables:
- customers(customer_id, customer_name, region)
- orders(order_id, customer_id, order_date)
- order_items(order_id, product_id, quantity, unit_price)
- products(product_id, product_name, category)

## Key Questions Answered
- Top customers by revenue
- Revenue by region and by product
- Monthly revenue trend
- Average order value (AOV)
- Customer activity (last order date) and inactive customers
- Top customers per region (window functions)
- Revenue concentration (top 20% share)

## Tools
- R (DBI, RSQLite) to load data and run queries
- SQLite database: `sales.db`

## Files
- `queries/business_analysis.sql` — all SQL queries used in the analysis
- `data/` — CSV tables used to build the SQLite database
