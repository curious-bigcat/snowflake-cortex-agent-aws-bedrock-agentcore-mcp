# AWS Setup Guide

Step-by-step instructions to set up S3 documents, Bedrock Knowledge Base, and AgentCore Gateway.

---

## Step 1: Create an S3 Bucket and Upload Documents

### 1.1 Create the bucket

1. Open the **S3 Console** -> **Create bucket**
2. Bucket name: `shopsmart-product-docs-<your-account-id>` (must be globally unique)
3. Region: pick the region where you want to run Bedrock (e.g., `us-east-1`)
4. Leave defaults, click **Create bucket**

### 1.2 Upload the documents

1. Open the bucket you just created
2. Click **Create folder** -> name it `documents` -> click **Create folder**
3. Open the `documents/` folder
4. Upload the contents of the `aws/s3-data/` directory from this repo:
   - `product-manuals/` (4 files)
   - `return-policies/` (3 files)
   - `shipping-guides/` (2 files)

You can drag and drop the three folders or use the AWS CLI:

```bash
aws s3 sync aws/s3-data/ s3://YOUR-BUCKET-NAME/documents/ --region <YOUR-REGION>
```

Your bucket should look like:

```
s3://your-bucket/
  documents/
    product-manuals/
      wireless-headphones-pro.md
      smartwatch-x1.md
      bluetooth-speaker-boombox.md
      laptop-stand-ergo.md
    return-policies/
      general-return-policy.md
      electronics-return-policy.md
      warranty-policy.md
    shipping-guides/
      domestic-shipping.md
      international-shipping.md
```

---

## Step 2: Create a Bedrock Knowledge Base

### 2.1 Subscribe to required models

1. Open **Amazon Bedrock Console** -> **Model access** (left sidebar under "Bedrock configurations")
2. Click **Modify model access**
3. Enable these models:
   - **Amazon Titan Text Embeddings V2** (for KB vector embeddings)
   - **Anthropic Claude Sonnet** (for RetrieveAndGenerate responses)
4. Click **Next** -> **Submit**
5. Wait for access status to show **Access granted**

### 2.2 Create the Knowledge Base

1. Open **Amazon Bedrock Console** -> **Knowledge bases** (left sidebar under "Orchestration")
2. Click **Create knowledge base**
3. Configure:
   - **Name**: `shopsmart-product-knowledge`
   - **Description**: `ShopSmart product documentation including manuals, return policies, shipping guides, and warranty information.`
   - **IAM permissions**: Select **Create and use a new service role**
   - Click **Next**
4. **Data source configuration**:
   - Data source name: `shopsmart-s3-documents`
   - S3 URI: Browse and select your bucket, then the `documents/` folder
   - Click **Next**
5. **Embeddings model**: Select **Titan Text Embeddings v2**
6. **Vector database**: Select **Quick create a new vector store** (uses OpenSearch Serverless)
7. Click **Next** -> **Create knowledge base**
8. Wait for status to show **Ready** (takes 2-5 minutes)

### 2.3 Sync and test the Knowledge Base

1. Once the KB is ready, select the data source and click **Sync**
2. Wait for the sync to complete (status shows number of documents indexed)
3. Test it using the **Test** panel on the right:
   - Type: "What is the return policy for electronics?"
   - You should get an answer citing the electronics return policy document
   - Type: "How do I pair the Wireless Headphones Pro?"
   - You should get pairing instructions from the manual

4. **Note down the Knowledge Base ID** (shown at the top of the KB detail page, format: `XXXXXXXXXX`)

---

## Step 3: Create a Cognito User Pool

Snowflake's MCP Connector requires OAuth (authorization_code flow) to authenticate users. You need a Cognito user pool that supports interactive login.

> **Important**: The AgentCore Gateway wizard auto-creates a Cognito pool when you
> create the gateway (Step 4), but that auto-created pool is configured for
> machine-to-machine (client_credentials) only and its app client is hidden in the
> Cognito console. For the Snowflake CoWork interactive login flow, you need a pool
> that supports **authorization_code** with a visible, configurable app client.
> Create the pool manually here BEFORE creating the gateway.

### 3.1 Create the pool

1. Open **Amazon Cognito Console** -> **Create user pool**
2. Application type: **Traditional web application** (this enables authorization_code flow, which CoWork requires)
3. Name: `shopsmart-gateway-pool`
4. Sign-in: **Email**
5. Self-registration: **Disabled**
6. Return URL: `https://identity.snowflake.com/oauth2/callback`
7. Click **Create**

### 3.2 Verify the domain was auto-created

The wizard auto-creates a Cognito domain. Find it by running in CloudShell:

```bash
aws cognito-idp describe-user-pool \
  --user-pool-id <YOUR-POOL-ID> \
  --region <YOUR-REGION> \
  --query "UserPool.Domain" --output text
```

Note this domain prefix -- the token/auth endpoints are:
- Token: `https://<domain>.auth.<region>.amazoncognito.com/oauth2/token`
- Authorize: `https://<domain>.auth.<region>.amazoncognito.com/oauth2/authorize`

### 3.3 Create a user for CoWork login

1. Go to **Users** tab -> **Create user**
2. Email: your email address
3. Set a temporary password (8+ chars, uppercase, lowercase, number, special char)
4. Create

### 3.4 Note down your values

| Value | Where to find it |
|-------|-----------------|
| **Pool ID** | Pool overview page (format: `<region>_xxxxxxxxx`) |
| **Client ID** | App clients section -> Client ID |
| **Client Secret** | App clients section -> Show client secret |
| **Domain** | From the CLI command above or the pool's domain settings |

---

## Step 4: Create an AgentCore Gateway

### 4.1 Create the Gateway

1. Open **Amazon Bedrock Console** -> **AgentCore** (left sidebar) -> **Gateways**
2. Click **Create gateway**
3. Configure:
   - **Name**: `shopsmart-cortex-gateway`
   - **Description**: `MCP Gateway exposing ShopSmart product KB for Snowflake Cortex Agent`
   - **MCP protocol versions**: Select `2025-11-25`
   - **Service role**: Let the wizard create a new role
   - **Inbound authorization**: Select **Amazon Cognito** (the wizard will auto-create its own pool, but we'll change this)
4. Click **Create gateway**
5. Wait for status to show **Ready**

### 4.2 Update Inbound Auth to use your manual pool

The gateway auto-creates its own Cognito pool, but we need to point it to the pool you created in Step 3 (which supports interactive login for CoWork).

1. On the gateway detail page, find **Inbound Auth** -> click **Edit**
2. Update:
   - **Discovery URL**: `https://cognito-idp.<YOUR-REGION>.amazonaws.com/<YOUR-POOL-ID>/.well-known/openid-configuration`
   - **Allowed clients**: `<YOUR-CLIENT-ID>` (from your manual pool)
3. Save

### 4.3 Add the Bedrock KB as a Target

1. Go to **Targets** tab -> **Add target**
2. Configure:
   - **Target type**: Select **Knowledge base**
   - **Name**: `shopsmart-product-kb`
   - **Description**: `ShopSmart product documentation knowledge base`
   - **Knowledge base**: Select `shopsmart-product-knowledge`
   - **Authorization**: Select **IAM (SigV4)** for outbound auth to the KB
3. Click **Add target**
4. Click **Sync** on the target row to discover its tools

### 4.4 Note down the Gateway URL

The gateway detail page shows the **Gateway resource URL**:
```
https://<gateway-id>.gateway.bedrock-agentcore.<region>.amazonaws.com/mcp
```

### 4.5 Test the Gateway

Use curl to verify the gateway can reach the KB:

```bash
# Get OAuth token from your manual Cognito pool
TOKEN=$(curl -s -X POST \
  "https://<domain>.auth.<region>.amazoncognito.com/oauth2/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=<client-id>&client_secret=<client-secret>" \
  | jq -r '.access_token')

# List tools
curl -s -X POST \
  "https://<gateway-id>.gateway.bedrock-agentcore.<region>.amazonaws.com/mcp" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":"1","method":"tools/list"}' | jq .
```

> **Note**: The curl test uses client_credentials (machine-to-machine). CoWork uses
> authorization_code (interactive login). Both work against the same Cognito pool
> as long as the app client has both grant types enabled. The "Traditional web
> application" wizard enables authorization_code by default. You may need to add
> client_credentials via the Cognito console or CLI if the curl test fails.

---

## Summary of values needed for Snowflake

| Value | Example |
|-------|---------|
| Gateway MCP URL | `https://<gateway-id>.gateway.bedrock-agentcore.<region>.amazonaws.com/mcp` |
| Cognito Client ID | From your manual Cognito pool's app client |
| Cognito Client Secret | From your manual Cognito pool's app client |
| Cognito Token endpoint | `https://<domain>.auth.<region>.amazoncognito.com/oauth2/token` |
| Cognito Auth endpoint | `https://<domain>.auth.<region>.amazoncognito.com/oauth2/authorize` |

These go into `snowflake/04_mcp_integration.sql`.

---

## Known Issues and Gotchas

1. **Do NOT set `OAUTH_ALLOWED_SCOPES` in the Snowflake API Integration.** Setting scopes (even `openid`) causes a 400 Bad Request from Snowflake's identity service during the OAuth flow. Leave the scopes parameter out entirely.

2. **Use `CLIENT_SECRET_POST`, not `CLIENT_SECRET_BASIC`.** Cognito's token endpoint works with both, but Snowflake's OAuth orchestration works more reliably with `CLIENT_SECRET_POST` for Cognito.

3. **The gateway auto-creates a Cognito pool**, but that pool is configured for machine-to-machine only and its client may not be accessible in the Cognito console. For CoWork (which requires interactive user login), create your own pool manually with "Traditional web application" type.

4. **Sync the gateway target** after adding the Knowledge Base. If you don't click Sync, the gateway won't discover any tools and `tools/list` returns empty.
