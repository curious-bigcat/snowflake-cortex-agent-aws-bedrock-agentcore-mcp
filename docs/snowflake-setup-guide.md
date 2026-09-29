# Snowflake Setup Guide

Step-by-step instructions to set up the Snowflake side: structured data, Cortex Search, Semantic View, MCP integration, and the Cortex Agent.

---

## Prerequisites

- Snowflake account with **Cortex Agents** and **CoWork** enabled
- A role with privileges to create databases, warehouses, and API integrations (ACCOUNTADMIN for the MCP integration step)
- The SQL scripts in the `snowflake/` directory

---

## Step 1: Create Database, Schema, and Warehouse

Run `snowflake/01_setup.sql` in a Snowflake worksheet (Snowsight).

This creates:
- Database: `RETAIL_DEMO`
- Schema: `RETAIL_DEMO.ECOMMERCE`
- Warehouse: `RETAIL_DEMO_WH` (X-Small, auto-suspend 120s)
- Role: `RETAIL_DEMO_ROLE` with Cortex AI privileges

---

## Step 2: Load Structured Data

Run `snowflake/02_structured_data.sql`.

This creates and populates four tables:

| Table | Rows | Description |
|-------|------|-------------|
| `CUSTOMERS` | 20 | Customer profiles with regions and loyalty tiers |
| `PRODUCTS` | 15 | Product catalog (names match S3 product manuals) |
| `ORDERS` | 65 | Orders from Apr-Oct 2024 |
| `RETURNS` | 15 | Returns with reasons and refund details |

Verify:
```sql
SELECT 'CUSTOMERS' AS tbl, COUNT(*) AS rows FROM CUSTOMERS
UNION ALL SELECT 'PRODUCTS', COUNT(*) FROM PRODUCTS
UNION ALL SELECT 'ORDERS', COUNT(*) FROM ORDERS
UNION ALL SELECT 'RETURNS', COUNT(*) FROM RETURNS;
```

---

## Step 3: Load Unstructured Data and Create Cortex Search

### 3a. Create the review and ticket tables

Run the **first half** of `snowflake/03_unstructured_data.sql` (the `CREATE TABLE` and `INSERT` statements for `PRODUCT_REVIEWS` and `SUPPORT_TICKETS`). This gives you:
- `PRODUCT_REVIEWS`: 50 reviews with ratings, product names, and review text
- `SUPPORT_TICKETS`: 20 tickets with issue descriptions and statuses

### 3b. Create Cortex Search Service (via Snowsight UI)

1. In Snowsight, go to **AI & ML** -> **Cortex Search**
2. Click **Create**
3. Select a role (e.g., `RETAIL_DEMO_ROLE`) and warehouse (`RETAIL_DEMO_WH`)
4. Select database `RETAIL_DEMO`, schema `ECOMMERCE`
5. Name the service: `PRODUCT_REVIEW_SEARCH`
6. Click **Next**
7. **Data source**: Select **Table or view**
8. You need to combine reviews and tickets into one source. The easiest way:
   - Create a view first by running this in a worksheet:
     ```sql
     CREATE OR REPLACE VIEW RETAIL_DEMO.ECOMMERCE.SEARCH_SOURCE AS
     SELECT
         review_text       AS chunk,
         product_name,
         category,
         'review'          AS source_type,
         reviewer_name     AS author,
         rating::VARCHAR   AS rating,
         review_date::VARCHAR AS doc_date
     FROM RETAIL_DEMO.ECOMMERCE.PRODUCT_REVIEWS
     UNION ALL
     SELECT
         description       AS chunk,
         product_name,
         category,
         'support_ticket'  AS source_type,
         customer_name     AS author,
         NULL              AS rating,
         created_date::VARCHAR AS doc_date
     FROM RETAIL_DEMO.ECOMMERCE.SUPPORT_TICKETS;
     ```
   - Back in the Cortex Search wizard, select the view `SEARCH_SOURCE`
   - Click **Next**
9. **Columns**: Select all columns (`chunk`, `product_name`, `category`, `source_type`, `author`, `rating`, `doc_date`), then click **Next**
10. **Search column**: Select `chunk` (this is the text that will be searched), click **Next**
11. **Filter columns**: Select `product_name`, `category`, and `source_type` (these become filterable attributes), click **Next**
12. **Target lag**: Set to `1 hour`
13. Click **Create**

The service will take a few minutes to build the search index.

**Alternatively**, you can skip the UI and run the full `snowflake/03_unstructured_data.sql` script which creates the search service via SQL directly.

### 3c. Verify

```sql
SHOW CORTEX SEARCH SERVICES IN SCHEMA RETAIL_DEMO.ECOMMERCE;

-- Test a search
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'RETAIL_DEMO.ECOMMERCE.PRODUCT_REVIEW_SEARCH',
    '{
      "query": "battery issues",
      "columns": ["chunk", "product_name", "source_type"],
      "limit": 3
    }'
  )
)['results'] AS results;
```

Note: The search service may take a few minutes to become available after creation.

---

## Step 4: Create the Semantic View (via Snowsight Autopilot)

Create the Semantic View using the **Snowsight UI** rather than SQL:

1. In Snowsight, go to **AI & ML** -> **Semantic Views**
2. Click **Create** -> select `RETAIL_DEMO` database, `ECOMMERCE` schema
3. Name it `RETAIL_SV` (or your preferred name)
4. Add all four tables: `CUSTOMERS`, `PRODUCTS`, `ORDERS`, `RETURNS`
5. Let **Autopilot** generate descriptions, relationships, and metrics
6. Review and adjust as needed -- ensure these relationships exist:
   - `ORDERS.customer_id` -> `CUSTOMERS.customer_id`
   - `ORDERS.product_id` -> `PRODUCTS.product_id`
   - `RETURNS.order_id` -> `ORDERS.order_id`
7. Add a few verified queries (optional but improves accuracy):
   - "Who are the top 5 customers by total spending?"
   - "What is the monthly revenue trend?"
   - "What is the return rate by product category?"
8. Click **Create**

**Important**: If you use a different name than `RETAIL_SV`, update the semantic view reference when creating the agent in Step 6.

Verify:
```sql
DESCRIBE SEMANTIC VIEW RETAIL_DEMO.ECOMMERCE.RETAIL_SV;
```

---

## Step 5: Configure the MCP Integration

**This step requires values from the AWS setup.** Make sure you have completed the [AWS Setup Guide](aws-setup-guide.md) first.

### 5.1 Edit the SQL script

Open `snowflake/04_mcp_integration.sql` and replace the placeholder values:

| Placeholder | Replace with |
|-------------|-------------|
| `<YOUR-GATEWAY-ID>` | AgentCore Gateway ID (from AWS console) |
| `<YOUR-REGION>` | AWS region (e.g., `us-east-1`) |
| `<YOUR-COGNITO-CLIENT-ID>` | Cognito App Client ID (from your manual pool) |
| `<YOUR-COGNITO-CLIENT-SECRET>` | Cognito App Client Secret |
| `<YOUR-COGNITO-DOMAIN>` | Cognito domain prefix (found via CLI or console) |

> **Gotcha**: Do NOT add `OAUTH_ALLOWED_SCOPES` -- it causes a 400 error.
> The script deliberately omits it. See "Known Issues" in the AWS guide.

### 5.2 Run the script

Run `snowflake/04_mcp_integration.sql` using **ACCOUNTADMIN** role (required for `CREATE API INTEGRATION`).

This creates:
- **API Integration** (`agentcore_gateway_integration`): OAuth2 connection config
- **External MCP Server** (`AWS_KNOWLEDGE_BASE`): Points to the AgentCore Gateway URL

### 5.3 Verify

```sql
SHOW EXTERNAL MCP SERVERS IN SCHEMA RETAIL_DEMO.ECOMMERCE;
DESCRIBE EXTERNAL MCP SERVER RETAIL_DEMO.ECOMMERCE.AWS_KNOWLEDGE_BASE;
```

Test the OAuth flow before proceeding:
```sql
-- This returns a URL; open it in your browser to verify the Cognito login page appears
SELECT SYSTEM$START_USER_OAUTH_FLOW('AGENTCORE_GATEWAY_INTEGRATION');
```

---

## Step 6: Create the Cortex Agent (via Snowsight UI)

1. In Snowsight, go to **AI & ML** -> **Agents**
2. Click **Create**
3. Configure the basics:
   - **Name**: `RETAIL_ASSISTANT`
   - **Database**: `RETAIL_DEMO`, **Schema**: `ECOMMERCE`
   - **Warehouse**: `RETAIL_DEMO_WH`
   - **Model**: Leave as `auto` (recommended) or pick a specific model

4. **Set the instructions** (paste this into the response instructions field):

   ```
   You are a retail customer service assistant for ShopSmart, an e-commerce
   company. You help employees and customers with product information, order
   lookups, return policies, and product feedback analysis.
   Always be specific and cite your sources. Format monetary values as USD.
   ```

5. **Add Tool 1: Cortex Analyst (structured data)**
   - Click **Add Tool** -> **Cortex Analyst**
   - Name: `RetailAnalyst`
   - Description: `Answers questions about structured retail data including customers, products, orders, returns, revenue, shipping methods, loyalty tiers, and business metrics.`
   - Semantic View: Select `RETAIL_DEMO.ECOMMERCE.RETAIL_SV`
   - Warehouse: `RETAIL_DEMO_WH`

6. **Add Tool 2: Cortex Search (reviews and tickets)**
   - Click **Add Tool** -> **Cortex Search**
   - Name: `ProductReviewSearch`
   - Description: `Searches across product reviews and customer support tickets to find feedback, sentiment, complaints, and issue patterns for ShopSmart products.`
   - Search Service: Select `RETAIL_DEMO.ECOMMERCE.PRODUCT_REVIEW_SEARCH`
   - Max results: `5`
   - Configure column descriptions:
     - `chunk`: searchable, description: "The review text or support ticket description"
     - `product_name`: filterable, description: "Product name. Values: Wireless Headphones Pro, SmartWatch X1, Bluetooth Speaker BoomBox, Laptop Stand Ergo"
     - `category`: filterable, description: "Product category. Values: Electronics, Accessories"
     - `source_type`: filterable, description: "Whether this is a review or support_ticket"

7. **Add Tool 3: MCP Connector (AWS Knowledge Base)**
   - Click **MCP Connectors** (in the agent config panel)
   - From the list of available connectors, select `AWS_KNOWLEDGE_BASE` (the External MCP Server created in Step 5)
   - Click **Add to agent**

8. **Set orchestration instructions** (paste into the orchestration instructions field):

   ```
   Choose the right tool based on the question:

   1. RetailAnalyst - Use for questions about structured business data:
      orders, revenue, customers, products, inventory, returns metrics,
      shipping, and any question that needs SQL aggregations or lookups.

   2. ProductReviewSearch - Use for questions about customer opinions,
      product feedback, sentiment, and support issues.

   3. AWS Knowledge Base (MCP) - Use for questions about product
      documentation, return/refund policies, shipping information,
      warranty terms, and product manuals/specifications.

   For complex questions that span multiple domains, use multiple tools
   and synthesize the results.
   ```

9. Click **Create**

### Verify

```sql
SHOW AGENTS IN SCHEMA RETAIL_DEMO.ECOMMERCE;
DESCRIBE AGENT RETAIL_DEMO.ECOMMERCE.RETAIL_ASSISTANT;
```

---

## Step 7: Test in CoWork

1. Open **Snowsight** -> **CoWork** (or **Snowflake Intelligence** in the left navigation)
2. You should see **RETAIL_ASSISTANT** in the agent list
3. Select it and start asking questions

If the MCP connector requires user authentication:
1. In the **Sources** panel, look for **Connectors**
2. Click **Connect** next to "AWS Product Knowledge Base"
3. Complete the OAuth flow
4. The connector should show as **Connected**

See the [Demo Script](../demo/demo_script.md) for sample questions to try.

---

## Execution Order Summary

| Order | Script | Role | What it does |
|-------|--------|------|-------------|
| 1 | `01_setup.sql` | ACCOUNTADMIN | Database, schema, warehouse, role |
| 2 | `02_structured_data.sql` | RETAIL_DEMO_ROLE | 4 tables with sample data |
| 3 | `03_unstructured_data.sql` (tables only) + Snowsight UI | RETAIL_DEMO_ROLE | Reviews, tickets, Cortex Search |
| 4 | Snowsight UI Autopilot | RETAIL_DEMO_ROLE | Semantic View for Cortex Analyst |
| 5 | `04_mcp_integration.sql` (fill in values) | ACCOUNTADMIN | API Integration + External MCP Server |
| 6 | Snowsight UI | RETAIL_DEMO_ROLE | Cortex Agent with all 3 tools |
| 7 | Connect MCP in CoWork | RETAIL_DEMO_ROLE | Log in via Cognito, test the agent |
