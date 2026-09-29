# Demo Script: ShopSmart Cross-Platform AI Agent

Use this script when presenting the demo. Open **Snowflake CoWork**, select the **RETAIL_ASSISTANT** agent, and walk through these questions.

---

## Opening (set the scene)

> "ShopSmart is an e-commerce company with data spread across two platforms.
> Their structured business data -- orders, customers, products, returns -- lives in Snowflake.
> Their product documentation -- manuals, return policies, shipping guides -- lives as files in AWS S3, indexed by Amazon Bedrock Knowledge Base.
>
> We've built a single Cortex Agent that can answer questions across BOTH platforms,
> using MCP (Model Context Protocol) to bridge Snowflake and AWS.
> Let's see it in action."

---

## Part 1: Snowflake Structured Data (Cortex Analyst)

These questions route to the Semantic View via Cortex Analyst and generate SQL.

### Question 1: Revenue leaders
```
Who are our top 5 customers by total spending?
```
Expected: Table of customers with total_spent, ordered descending.

### Question 2: Trend analysis
```
Show me the monthly revenue trend for 2024
```
Expected: Monthly breakdown from April to October 2024.

### Question 3: Return analysis
```
What is the return rate by product category?
```
Expected: Categories with order count, return count, and percentage.

### Question 4: Specific lookup
```
Show me all orders for Sarah Johnson
```
Expected: List of Sarah's orders with dates, products, amounts, and status.

---

## Part 2: Snowflake Unstructured Data (Cortex Search)

These questions search across product reviews and support tickets.

### Question 5: Product feedback
```
What are customers saying about the Wireless Headphones Pro?
```
Expected: Summarized review highlights (ANC, battery, comfort, connectivity issues).

### Question 6: Issue detection
```
What are the most common support ticket issues for the SmartWatch X1?
```
Expected: Summary of software sync issues, condensation/water damage, connectivity, battery drain.

### Question 7: Sentiment check
```
Are there any battery complaints across our products?
```
Expected: Hits from headphones (15hr vs 40hr), speaker (3hr vs 20hr), and smartwatch (2-day drain).

---

## Part 3: AWS Data via MCP (Bedrock Knowledge Base)

These questions route through the MCP Connector to AgentCore Gateway to Bedrock KB, which searches the S3 documents.

### Question 8: Return policy
```
What is the return policy for electronics?
```
Expected: 30-day window, conditions, restocking fees -- sourced from electronics-return-policy.md.

### Question 9: Product manual
```
How do I pair the Wireless Headphones Pro with my phone?
```
Expected: Step-by-step Bluetooth pairing instructions from the product manual.

### Question 10: Shipping info
```
What are the shipping options and costs for domestic orders?
```
Expected: Standard ($5.99), Expedited ($12.99), Next-Day ($24.99), Same-Day ($14.99) with thresholds.

### Question 11: Warranty
```
What does the warranty cover for electronics, and how do I file a claim?
```
Expected: 1-year for audio/wearables, 2-year for laptops, claim process steps.

---

## Part 4: Cross-Platform Questions (the wow moment)

These questions require the agent to use MULTIPLE tools across both platforms.

### Question 12: Return + order lookup
```
A customer named David Thompson wants to return their SmartWatch X1.
What's the return policy and can you show me their order history?
```
Expected: Agent uses MCP for electronics return policy (30-day window) AND Cortex Analyst
for David's orders. Should show the order and note whether it's within the return window.

### Question 13: Product issues + documentation
```
Customers are complaining about battery life on the Bluetooth Speaker BoomBox.
What does the manual say about expected battery life, and what are the actual complaints?
```
Expected: Agent uses Cortex Search for complaints (3hr battery life) AND MCP for the manual
specs (20 hours at 50% volume, 6000mAh battery). Nice contrast between promise and reality.

### Question 14: Returns + warranty analysis
```
Show me the most returned products and the warranty coverage for each
```
Expected: Agent uses Cortex Analyst for return data (Headphones Pro: 5 returns, SmartWatch: 3, etc.)
AND MCP for warranty policy (1-year for audio, 1-year for wearables).

### Question 15: Full cross-platform synthesis
```
Give me a complete analysis of the Wireless Headphones Pro:
sales performance, customer feedback, common issues, and return policy
```
Expected: Agent uses all three tools:
- Cortex Analyst: sales numbers, revenue, return rate
- Cortex Search: review highlights and support ticket themes
- MCP: manual specs and return policy details

---

## Closing points

After the demo, highlight:

1. **Single agent, multiple data sources** -- structured (Snowflake tables), unstructured (Snowflake stage + Cortex Search), and external (AWS S3 + Bedrock KB) -- all unified.

2. **MCP as the bridge** -- AgentCore Gateway exposes AWS capabilities as MCP tools that Snowflake Cortex Agent can call natively. No custom code or APIs needed.

3. **CoWork as the interface** -- Business users ask natural language questions without knowing where data lives. The agent routes automatically.

4. **Governed and secure** -- Snowflake RBAC controls who can access the agent and data. OAuth secures the cross-platform MCP connection. Bedrock KB access is controlled by IAM.

5. **Bidirectional** -- The optional Managed MCP Server means AWS agents can also query Snowflake data through the same MCP standard.
