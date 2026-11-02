# Mini Business Report: Retail Sales & Workforce Overview

## Executive summary
This project combines transaction-level sales with customer and employee data to show how SQL can support commercial and workforce decisions. The included dataset is intentionally small and illustrative; conclusions should be treated as a demonstration of the analytical workflow, not as claims about a real company.

## What the analysis measures
1. **Revenue momentum:** monthly completed-order sales and month-over-month growth, using `LAG`.
2. **Customer value:** historical spend and completed-order count by customer.
3. **Product/category performance:** net sales, units sold, and share of total sales.
4. **Sales effectiveness:** average order value, sales by channel, and repeat-purchase rate.
5. **Workforce movement:** current status by department and dated termination events.

## Findings to validate when queries are run
- The top-customer query identifies the customers who contribute the most historical revenue; use this to prioritise retention outreach and loyalty benefits.
- The MoM query highlights growth and contraction periods. Investigate the underlying order mix before attributing a change to a campaign or seasonality.
- Category and product rankings reveal where merchandising, bundles, or inventory attention may have the highest payoff.
- Repeat-purchase rate helps distinguish one-time acquisition from returning-customer behaviour.
- Department-level termination indicators can flag areas for further HR review, but should not be interpreted as causal evidence.

## Recommended business actions
- Create a monthly sales scorecard tracking net sales, order count, purchasing customers, average order value, and MoM growth.
- Segment customers by lifetime value and order recency; test a retention campaign for high-value customers who have not purchased recently.
- Review discounts by product/category to ensure that sales growth is not being bought at an unsustainable margin cost.
- Compare online, store, and phone channels on both revenue and order value, then test channel-specific improvements.
- Review employee exits alongside tenure, role, manager, and voluntary/involuntary reason before making workforce decisions.

## Limitations and next steps
- The sample contains only a handful of customers, products, orders, and employees.
- Sales are revenue, not profit: product cost, shipping, tax, refunds, and returns accounting are not modelled.
- The sample does not include a complete monthly employee headcount snapshot. A standard attrition rate requires period terminations divided by average headcount for that period.
- Next version: add returns/refunds, product cost and margin, campaign data, inventory, employee snapshots, and automated dashboard charts.

## How to present this project in an interview
“I designed a relational retail analytics database in PostgreSQL, added PK/FK and validation constraints, and wrote 20 business queries. I used CTEs and window functions for month-over-month growth, running totals, ranking, and customer value. I created reporting views and a stored procedure to validate and create an order. I documented the business implications and metric limitations in a short report.”
