# Marketing Performance Analysis: Finding Where Revenue Leaks in the Funnel

SQL and Python portfolio project analyzing marketing channel performance, campaign effectiveness, and cart abandonment for an e-commerce business.

## Project Information

**Role:** Data Analyst, Independent Project
**Tools:** Python (Pandas), MySQL, Power BI
**Completed:** August 2026

This project uses the [Marketing & E-Commerce Analytics Dataset](https://www.kaggle.com/datasets/geethasagarbonthu/marketing-and-e-commerce-analytics-dataset) from Kaggle. The business case, questions, and analysis were built independently on top of this public dataset.

## Business Problem

The marketing team had traffic and transaction data from five channels — Email, Paid Search, Social, Organic, and Direct — but no clear read on which channel actually drove purchases, which campaigns were pulling their weight, or where customers were dropping off before checkout.

## Objective

Analyze traffic, campaigns, transactions, and product data to help the marketing team understand channel effectiveness, find the biggest leak in the funnel, and flag where to look next.

## Business Questions

1. Which traffic channel has the highest and lowest view-to-purchase conversion rate?
2. Which campaigns generate the most revenue, and how does that compare to their expected uplift?
3. What's the cart abandonment rate, and how much revenue does it represent?
4. Which product category contributes the most revenue?
5. Are there categories with high sales volume but low revenue per unit?

## Dataset

Five tables: `campaigns`, `customers`, `events` (2M+ rows), `products`, `transactions` (100K+ rows).

**A note on the dataset's limits:** there's no campaign cost or budget data here, so this analysis doesn't calculate ROI or claim which campaign is most profitable. `expected_uplift` is only a target percentage, not an absolute revenue target, and there's no baseline revenue from before each campaign ran so campaigns are compared by rank against each other, not by actual uplift.

## Tools and Concepts Used

Python (Pandas), MySQL, JOINs, CTEs, correlated subqueries, conditional aggregation (`CASE WHEN`), `NULLIF`, Power BI, Power Query.

## Analysis Process

- Cleaned five raw tables in Python (Pandas): standardized `traffic_source` casing, handled missing `product_id`/`device_type`, flagged incomplete transactions.
- Cross-checked transaction timestamps against customer `signup_date`.
- Decided not to use `signup_date` for cohort or tenure analysis after finding a major dating anomaly (more on that below).
- Loaded the cleaned tables into MySQL and adjusted date data types.
- Wrote SQL to calculate conversion rate by channel, campaign performance, cart abandonment, and revenue by category.
- Found a double-counting issue in the revenue-per-channel numbers and rewrote the query with first-touch attribution.
- Built a six-page Power BI dashboard: Overview, Channel, Funnel, Campaign, Category, and Recommendations.
- Added a Gap column in Power Query to compare each campaign's revenue rank against its expected-uplift rank, and a KPI card counting how many campaigns over- or underperformed.

## Key Findings

**Almost a third of carts get abandoned.**
Total revenue in the dataset is Rp8.6M, and 79.8% of it comes from campaign-attributed transactions. 35.95% of carts get abandoned before checkout, which works out to roughly Rp2.92M in potential revenue that never landed. Put simply: almost one in three customers who add something to their cart never finish the purchase.

**Cart abandonment isn't a one-channel problem.**
My first instinct was to check whether one channel was driving more abandonment than the others. It isn't — the rate is nearly identical everywhere, between 35.8% and 36.2%. That doesn't prove checkout is the cause, but a pattern this consistent across every channel points toward something all customers run into at the same stage — payment options, page load, checkout form length, or unexpected fees are the usual suspects.

**Electronics carries the most revenue.**
Electronics accounts for 41.2% of total revenue. Grocery has the lowest revenue per unit at Rp15.58, compared to Rp125.38 for Electronics. There's no cost data here, so I can't say anything about margin — but Grocery is worth a second look in terms of pricing, bundling, or its role in the overall product strategy.

**Organic brings the most traffic and converts the worst.**
Organic generated about 430K of the 1.04M total views the largest volume of any channel — but converted at just 3.9%, well behind Email (17.7%), Paid Search (16.7%), and Social (14.3%). More traffic doesn't automatically mean a channel is working. Organic probably doesn't need more volume; it needs its traffic quality, keywords, landing pages, and post-click experience checked first.

**A handful of campaigns need a closer look.**
Of the 50 campaigns evaluated, most tracked reasonably close to their expected-uplift ranking. Nine fell well below what was expected based on the rank comparison, and five beat it. Affiliate came up most consistently among the campaigns that outperformed their target.

## What I Learned

- Date columns need to be validated before they're used for anything like cohort analysis or customer tenure — I wouldn't have caught this otherwise.
- Comparing transaction timestamps to `signup_date`, I found 49% of transactions were recorded as happening before the customer had even signed up. That's too large and too systematic to be a fluke, so I dropped `signup_date` from any cohort or tenure work rather than build on top of a broken assumption.
- `events.csv` has 2 million rows. Opening it in Excel silently truncated it to 1,048,575 rows with no warning — I only caught it because the numbers looked off. I check row counts on large files before trusting them now.
- A join result should always be checked against a verified total. If the joined total comes out higher than the real total, something is being double-counted.
- I used first-touch attribution so a transaction wouldn't get counted more than once when a customer had more than one traffic source attached to them.
- A scatter plot read a lot better than a dual-axis chart for comparing views and conversion rate, since the two are on very different scales.
- On the business side: high traffic doesn't automatically mean a channel is doing its job.
- A metric that looks the same everywhere can still be useful — the fact that cart abandonment barely varies by channel actually helped narrow down where to look next, rather than being a dead end.
- Without cost data, I can't claim anything about ROI or margin. Saying what the data can't tell you is more useful than forcing a conclusion it doesn't support.

## Mistakes I Found and Fixed

**Opened a 2-million-row file in Excel.**
It silently truncated to 1,048,575 rows. I didn't notice right away — I only caught it once the totals didn't add up.

**Double-counted revenue by channel.**
My first query joined transactions to traffic source directly, without accounting for customers who had more than one source attached to them. That inflated total revenue per channel past the verified overall total. I rewrote it using first-touch attribution so each transaction only counts once.

## What I'd Do Differently Next Time

- Dig deeper into customer behavior — new vs. returning customers, purchase frequency, or what a customer's pattern looks like right before they abandon a cart.
- Check landing page performance per channel to see whether Organic's low conversion comes from traffic quality, page relevance, or the user experience itself.

## Recommendations

**Audit the checkout experience.**
A 35.95% abandonment rate that's roughly even across every channel makes checkout worth investigating directly — payment options, load time, number of form fields, checkout errors, extra fees, and the mobile checkout experience specifically. A cart-recovery email is also worth testing.

**Evaluate Organic on conversion, not traffic.**
Before pushing more traffic to Organic, check keyword quality, content relevance, landing pages, calls to action, and what customers actually do once they land from that channel.

**Look into the underperforming campaigns.**
The nine campaigns that fell well short of their expected uplift are worth revisiting — targeting, messaging, the product being promoted, timing, distribution channel, and landing page are all worth checking. Affiliate is a reasonable starting point for spotting what a better-performing campaign looks like, though any budget reallocation still needs cost data to back it up.

**Reassess the product category strategy.**
Electronics is the clear revenue driver. Grocery's low revenue per unit doesn't necessarily mean it's unimportant to the business — it might be a better fit for bundling, specific promotions, or a repeat-purchase strategy. Any further conclusion here still needs cost and profitability data.

## SQL Files

`q1_conversion_rate_per_channel.sql` — view-to-purchase conversion rate by traffic source.

`q2a_organic_vs_campaign_revenue.sql` — revenue split between organic and campaign-attributed transactions.

`q2b_revenue_vs_expected_uplift_per_campaign.sql` — ranks each campaign's actual revenue against its expected-uplift target.

`q3a_cart_abandonment_rate.sql` — overall cart abandonment rate.

`q3b_abandonment_rate_per_channel.sql` — cart abandonment rate broken down by channel.

`q3c_estimasi_revenue_hilang.sql` — estimated revenue lost to cart abandonment.

`q4a_revenue_per_category.sql` — revenue contribution and ranking by product category.

`q4b_revenue_per_unit_by_category.sql` — revenue per unit by category.

## Data Source

Dataset: [Marketing & E-Commerce Analytics Dataset](https://www.kaggle.com/datasets/geethasagarbonthu/marketing-and-e-commerce-analytics-dataset), Kaggle.

## Author

**Sayed Furqan**

Data Analyst Portfolio: [sayedfurqan.lovable.app](https://sayedfurqan.lovable.app)
