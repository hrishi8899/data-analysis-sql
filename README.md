# Data Analysis for Business and Decision-Making — SQL Project

## Project overview
A portfolio-ready PostgreSQL project that analyses retail sales, customer value, product performance, and employee attrition. It demonstrates relational schema design, keys and constraints, joins, aggregations, subqueries, CTEs, window functions, views, and a stored procedure.

## Business questions
- Who are the highest-value customers?
- How are sales changing month over month?
- Which product categories and products generate the most revenue?
- What is the average order value and repeat-purchase rate?
- Which sales channel contributes most to revenue?
- How does the employee roster and termination history vary by department?

## Tech stack
- PostgreSQL 14+
- SQL (DDL, DML, CTEs, window functions, views, PL/pgSQL stored procedure)
- Optional: DBeaver, pgAdmin, or psql

## Data model
- `customers` — customer profile and segment
- `products` — catalogue, category, current price and active flag
- `orders` — customer order header, date, status and channel
- `order_items` — product lines, quantity, transaction price and discount
- `employees` — employee profile, department, salary and current status
- `employee_status_history` — dated employment-status events

### Relationship summary
`customers 1 ── * orders 1 ── * order_items * ── 1 products`

`employees 1 ── * employee_status_history`

Primary keys identify each record. Foreign keys protect relationships. CHECK constraints validate status, quantity, discounts, and salary. Indexes support common join/filter patterns.

## Run it
Create an empty PostgreSQL database, then execute these files in order:

1. `schema.sql`
2. `sample_data.sql`
3. `queries.sql`
4. `procedures.sql`

Example with `psql`:
```bash
createdb business_analysis
psql -d business_analysis -f schema.sql
psql -d business_analysis -f sample_data.sql
psql -d business_analysis -f queries.sql
psql -d business_analysis -f procedures.sql
```

The schema file drops and recreates the project tables/views, so do not run it against a database containing data you need to keep.

## Deliverables
- `schema.sql` — 6 related tables, PKs, FKs, constraints, indexes and 3 views
- `sample_data.sql` — reproducible demonstration data
- `queries.sql` — 20 business-oriented SQL queries
- `procedures.sql` — validated order-creation procedure
- `insights.md` — sample interpretation and recommendations
- `README.md` — setup, model and usage notes

## SQL concepts demonstrated
- `SELECT`, filtering, `GROUP BY`, `HAVING`, `CASE`
- `INNER JOIN`, `LEFT JOIN`, anti-join pattern
- scalar subqueries and CTEs
- `COUNT`, `SUM`, `AVG`, `FILTER`
- `ROW_NUMBER`/`RANK`/`DENSE_RANK`-style ranking (RANK and DENSE_RANK included)
- `LAG` for MoM comparison
- running totals with window frames
- views and a PL/pgSQL stored procedure

## Important metric notes
- Sales use completed orders only and calculate line net sales as `quantity × unit_price × (1 − discount_pct / 100)`.
- Customer lifetime value is historical completed-order spend, not a forward-looking prediction.
- `vw_employee_attrition_summary` shows cumulative terminations divided by all employee records. That is a simple roster-level indicator, not a standard period attrition rate.
- A robust HR attrition rate needs terminations during the period divided by average headcount during that same period. The query pack calls out this limitation so the metric is not misrepresented.

## Mini business report
See `insights.md` for the business narrative and recommendations.
