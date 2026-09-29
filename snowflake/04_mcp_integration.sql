/*
 * 04_mcp_integration.sql
 *
 * Creates the API Integration and External MCP Server that connects
 * the Snowflake Cortex Agent to the AWS AgentCore Gateway.
 *
 * BEFORE RUNNING: Replace all <PLACEHOLDER> values with your actual
 * AWS Cognito and AgentCore Gateway values from the AWS setup guide.
 *
 * IMPORTANT gotchas (see aws-setup-guide.md "Known Issues"):
 *   - Do NOT add OAUTH_ALLOWED_SCOPES -- causes 400 errors
 *   - Use CLIENT_SECRET_POST (not CLIENT_SECRET_BASIC) for Cognito
 *
 * Run after: AWS setup is complete (Steps 1-4 in aws-setup-guide.md)
 */

USE ROLE ACCOUNTADMIN;  -- Required for CREATE API INTEGRATION

-- ============================================================
-- API Integration (OAuth connection to AgentCore Gateway)
-- ============================================================

CREATE OR REPLACE API INTEGRATION agentcore_gateway_integration
    API_PROVIDER = external_mcp
    API_ALLOWED_PREFIXES = (
        'https://<YOUR-GATEWAY-ID>.gateway.bedrock-agentcore.<YOUR-REGION>.amazonaws.com'
    )
    API_USER_AUTHENTICATION = (
        TYPE = OAUTH2
        OAUTH_CLIENT_ID = '<YOUR-COGNITO-CLIENT-ID>'
        OAUTH_CLIENT_SECRET = '<YOUR-COGNITO-CLIENT-SECRET>'
        OAUTH_TOKEN_ENDPOINT = 'https://<YOUR-COGNITO-DOMAIN>.auth.<YOUR-REGION>.amazoncognito.com/oauth2/token'
        OAUTH_CLIENT_AUTH_METHOD = CLIENT_SECRET_POST
        OAUTH_AUTHORIZATION_ENDPOINT = 'https://<YOUR-COGNITO-DOMAIN>.auth.<YOUR-REGION>.amazoncognito.com/oauth2/authorize'
        OAUTH_REFRESH_TOKEN_VALIDITY = 86400
    )
    ENABLED = TRUE;

-- ============================================================
-- External MCP Server (Snowflake <-> AgentCore Gateway bridge)
-- ============================================================

CREATE OR REPLACE EXTERNAL MCP SERVER RETAIL_DEMO.ECOMMERCE.AWS_KNOWLEDGE_BASE
    WITH DISPLAY_NAME = 'AWS Product Knowledge Base'
    URL = 'https://<YOUR-GATEWAY-ID>.gateway.bedrock-agentcore.<YOUR-REGION>.amazonaws.com/mcp'
    API_INTEGRATION = agentcore_gateway_integration;

-- ============================================================
-- Grant access
-- ============================================================

GRANT USAGE ON EXTERNAL MCP SERVER RETAIL_DEMO.ECOMMERCE.AWS_KNOWLEDGE_BASE
    TO ROLE RETAIL_DEMO_ROLE;

GRANT USAGE ON INTEGRATION agentcore_gateway_integration
    TO ROLE RETAIL_DEMO_ROLE;

-- ============================================================
-- Verify
-- ============================================================

SHOW EXTERNAL MCP SERVERS IN SCHEMA RETAIL_DEMO.ECOMMERCE;

DESCRIBE EXTERNAL MCP SERVER RETAIL_DEMO.ECOMMERCE.AWS_KNOWLEDGE_BASE;

-- Test the OAuth flow (open the resulting URL in a browser):
-- SELECT SYSTEM$START_USER_OAUTH_FLOW('AGENTCORE_GATEWAY_INTEGRATION');
