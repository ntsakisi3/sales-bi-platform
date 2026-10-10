# Business Requirements Document
## Sales Business Intelligence Platform

### 1. Project Overview
A mid-sized distribution company sells products across multiple regions through a team of sales representatives. Leadership currently reviews performance using static monthly spreadsheets exported from the order system, which are slow to produce and already out of date by the time they're reviewed. This project builds a SQL-backed analytics layer and Power BI dashboard so management can see sales, profit, and rep/product/region performance in near real time.

### 2. Business Problem
| Issue | Impact |
|---|---|
| Monthly manual spreadsheet exports | Data is 2–4 weeks stale by the time it's reviewed |
| No single source of truth | Finance, Sales, and regional managers each keep their own version of "the numbers" |
| No product/region/rep drill-down | Leadership can see totals but can't see *why* a number moved |
| No trend visibility | Hard to spot underperforming products or reps early enough to act |
| Manual profit calculation | Profit margin is calculated ad hoc in Excel, inconsistently |

### 3. Business Objectives
1. Give management a single, trusted view of revenue and profit, refreshed regularly rather than monthly.
2. Enable drill-down by region, product, salesperson, and time period.
3. Surface underperforming products and reps early enough to act on them.
4. Reduce the time Finance spends assembling sales reports.

### 4. Stakeholders
| Stakeholder | Interest |
|---|---|
| Sales Director | Team and regional performance, pipeline health |
| Regional Managers | Their region's rep performance and targets |
| Finance | Revenue, profit, margin accuracy |
| Sales Representatives | Their own performance vs. targets |
| Executive team | High-level KPIs for strategic decisions |

### 5. Scope
**In scope:** Customers, Products, Orders, Order Line Items, Employees/Sales Reps, Regions, a date dimension, and SQL reporting queries feeding a Power BI dashboard.

**Out of scope (Phase 1):** Real-time POS integration, automated anomaly alerting, forecasting/predictive models.

### 6. Expected Business Benefits
- Faster, more accurate decision-making from a single trusted data source
- Early visibility into underperforming products/regions/reps
- Reduced manual reporting effort for Finance (estimated 4–6 hours/month saved)
- Consistent profit/margin definitions used company-wide

### 7. Key Business Questions the Platform Must Answer
1. What is total revenue and profit, and how is it trending month over month?
2. Which regions, products, and salespeople are over/under-performing?
3. Who are the top customers by revenue, and which are at risk of churn (declining order frequency)?
4. What is the average order value, and how does it vary by region/segment?
5. Which products have low or negative margin and should be reviewed?
