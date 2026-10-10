# Power BI Dashboard Specification
## Sales Business Intelligence Platform

This spec is written so the dashboard can be built directly in Power BI Desktop against the database created from `database/schema.sql` + `database/seed.sql` (or against CSV exports of the same tables, if connecting straight to Postgres isn't available).

### 1. Data Model (import these tables)
`regions`, `employees`, `customers`, `products`, `date_dim`, `orders`, `order_items`

**Relationships (star schema):**
- `orders[employee_id]` → `employees[employee_id]` (many-to-one)
- `orders[customer_id]` → `customers[customer_id]` (many-to-one)
- `orders[region_id]` → `regions[region_id]` (many-to-one)
- `orders[order_date]` → `date_dim[date_id]` (many-to-one) — mark `date_dim` as the **Date Table** in Power BI
- `order_items[order_id]` → `orders[order_id]` (many-to-one)
- `order_items[product_id]` → `products[product_id]` (many-to-one)

### 2. Key DAX Measures
```dax
Total Revenue = SUM(order_items[line_revenue])
Total Profit = SUM(order_items[line_profit])
Margin % = DIVIDE([Total Profit], [Total Revenue], 0)
Total Orders = DISTINCTCOUNT(orders[order_id])
Avg Order Value = DIVIDE([Total Revenue], [Total Orders], 0)
Units Sold = SUM(order_items[quantity])

Revenue PY = CALCULATE([Total Revenue], SAMEPERIODLASTYEAR(date_dim[date_id]))
Revenue YoY % = DIVIDE([Total Revenue] - [Revenue PY], [Revenue PY], 0)

Revenue MoM % =
VAR CurrMonth = [Total Revenue]
VAR PrevMonth = CALCULATE([Total Revenue], DATEADD(date_dim[date_id], -1, MONTH))
RETURN DIVIDE(CurrMonth - PrevMonth, PrevMonth, 0)
```

### 3. Page 1 — Executive Overview
**KPI cards (top row):** Total Revenue · Total Profit · Margin % · Total Orders · Avg Order Value

**Visuals:**
- Line chart: Monthly Revenue & Profit trend (`date_dim[month_name]` on X, `[Total Revenue]` and `[Total Profit]` as two lines)
- Bar chart: Revenue by Region (`regions[region_name]` vs `[Total Revenue]`)
- Donut chart: Revenue by Product Category
- Slicers: Year, Region, Customer Segment

### 4. Page 2 — Product Performance
- Table: Product name, Category, Units Sold, Revenue, Profit, Margin % (sortable, top-N filter)
- Bar chart: Top 10 products by revenue
- Bar chart: Bottom 5 products by revenue (flag for review)
- Scatter chart: Margin % (Y) vs. Units Sold (X) per product — quickly spot high-volume/low-margin products

### 5. Page 3 — Salesperson & Regional Performance
- Table: Salesperson, Region, Orders Handled, Revenue, Profit, Avg Order Value
- Bar chart: Revenue by salesperson, grouped/colored by region
- Map or bar chart: Revenue by region
- Line chart: Orders per salesperson per month (activity trend)

### 6. Page 4 — Customer Analysis
- KPI cards: Total Customers, New Customers (this quarter), Top Customer Revenue
- Table: Top 10 customers by revenue (name, segment, revenue, order count)
- Bar chart: Revenue by customer segment (Retail/Wholesale/Online)
- Table: Customers with declining order frequency (churn-risk flag) — sourced from `queries.sql` query 17

### 7. Interactivity
- All pages share a common Year/Region/Segment slicer panel (synced across pages)
- Cross-filtering enabled: clicking a region on Page 1 filters Page 2 and Page 3 visuals
- Drillthrough: right-click a salesperson on Page 3 → drillthrough to a "Rep Detail" page showing their order history

### 8. Business Insights Expected From This Data
Based on the seed dataset's generation pattern (which intentionally varies region demand, product margins, and order frequency), the dashboard is expected to surface:
- Gauteng and Western Cape carrying the largest share of revenue, reflecting larger assigned customer bases
- Kitchen Appliances as a high-volume category but with tighter margins than Electronics
- A small number of Wholesale customers contributing a disproportionate share of total revenue (Pareto effect) — see query 18
- Seasonal/monthly variation in order volume that a static spreadsheet report would miss between review cycles

### 9. Recommendations Template for Management
After connecting live data, populate this section with actual findings, e.g.:
- "Review pricing on [low-margin product] — margin is below the 25% category average."
- "[Region] is underperforming relative to headcount — consider reallocating rep coverage."
- "Top 20% of customers drive ~X% of revenue — prioritise account management for this segment."
