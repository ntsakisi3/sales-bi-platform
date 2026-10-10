# Sales Business Intelligence Platform

## 1. Project Overview
A SQL + Power BI analytics solution giving management a single, trusted, drill-down view of revenue, profit, and performance across regions, products, salespeople, and customers — replacing slow, inconsistent manual spreadsheet reporting.

## 2. Business Problem
Monthly manual spreadsheet exports leave leadership working from stale, inconsistent numbers with no ability to drill into *why* performance moved. Full detail: [`docs/business-requirements.md`](docs/business-requirements.md).

## 3. Proposed Solution
A star-schema SQL database (customers, products, orders, order items, employees, regions, a date dimension) feeding a multi-page Power BI dashboard with KPI cards, trend charts, and drill-down by region/product/rep/customer.

## 4. Objectives
- Single trusted source for revenue/profit numbers
- Drill-down by region, product, salesperson, time period
- Early visibility into underperforming products/reps
- Reduced manual reporting effort for Finance

## 5. Stakeholders
Sales Director, Regional Managers, Finance, Sales Representatives, Executive team. Detail in [`docs/business-requirements.md`](docs/business-requirements.md).

## 6. Database Design
Star-schema design: `orders` and `order_items` as fact tables; `customers`, `products`, `employees`, `regions`, `date_dim` as dimensions. `line_revenue` and `line_profit` are computed columns so every report uses one consistent profit definition.
- Schema: [`database/schema.sql`](database/schema.sql)
- Realistic sample data — 20 customers, 15 products, 8 reps across 4 regions, 260 orders / ~630 line items spanning Jan 2025–Sep 2026: [`database/seed.sql`](database/seed.sql)
- 22 reporting queries: [`database/queries.sql`](database/queries.sql)

## 7. SQL Queries
Covers revenue, profit, monthly/quarterly/YoY trends, customer and product performance, regional performance, salesperson performance, average order value, churn-risk detection, Pareto revenue concentration, and day-of-week patterns. See [`database/queries.sql`](database/queries.sql) for all 22, numbered and commented.

## 8. Power BI Dashboard
Full build spec — data model, relationships, DAX measures, and a 4-page layout (Executive Overview, Product Performance, Salesperson & Regional Performance, Customer Analysis): [`powerbi/dashboard-specification.md`](powerbi/dashboard-specification.md)

> **Note:** this repo ships the dashboard as a build specification rather than a `.pbix` file, since Power BI Desktop isn't available in this environment. The spec is written so the dashboard can be built directly from `schema.sql`/`seed.sql` — every visual maps to a query already written in `queries.sql`.

## 9. Technologies
PostgreSQL (schema and queries), Power BI (dashboard spec + DAX), Python (used only to generate realistic seed data — see `database/seed.sql` generation notes below).

## 10. Features
- Star-schema database with computed revenue/profit columns (single source of truth for margin)
- 22 ready-to-run reporting queries
- Full Power BI build spec: data model, DAX measures, 4 dashboard pages, drillthrough and cross-filtering design

## 11. Installation
```bash
psql -U youruser -d salesbi -f database/schema.sql
psql -U youruser -d salesbi -f database/seed.sql
```
Then run any query from `database/queries.sql` directly, or connect Power BI Desktop to the `salesbi` database and follow `powerbi/dashboard-specification.md`.

## 12. How to Run
1. Create the database and run the schema + seed scripts above.
2. Run queries from `database/queries.sql` to validate the data (e.g. query 1 for a quick revenue/profit sanity check).
3. Open Power BI Desktop → Get Data → PostgreSQL → connect → import the 6 tables listed in the dashboard spec → build pages per the spec.

## 13. Testing
Schema was reviewed for referential integrity (every FK has a matching PK path) and the seed generator was run to confirm realistic distribution: 260 orders / ~630 line items across 4 regions, 8 reps, 20 customers, 15 products, Jan 2025–Sep 2026. Each of the 22 queries was manually traced against the schema for correct joins and aggregation logic.

## 14. Results
A working analytics layer that answers the five key business questions in `docs/business-requirements.md` §7 directly from SQL, with a dashboard spec ready to visualise the same data.

## 15. Business Value
Estimated 4–6 hours/month saved in manual Finance reporting, a single consistent definition of "profit" used company-wide, and earlier visibility into underperforming products/regions/reps than monthly spreadsheet cycles allow.

## 16. Future Improvements
- Live connection from Power BI to a production order system (replacing the static seed dataset)
- Automated anomaly alerts (e.g. a rep or product dropping sharply month-over-month)
- Customer lifetime value and basic churn-probability modelling
- Target/quota tracking per salesperson, not just actuals
