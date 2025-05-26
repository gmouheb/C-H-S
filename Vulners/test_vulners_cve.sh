#!/bin/bash

# Script to test the Vulners_CVE analyzer with CURL

# Configuration
CORTEX_URL="http://localhost:9001"
API_KEY=""  # Replace with your Cortex API key
CVE_ID="CVE-2021-44228"  # Example CVE ID, can be changed

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Vulners_CVE Analyzer Test Script${NC}"
echo "==============================="
echo ""

# Check if API key is provided
if [ -z "$API_KEY" ]; then
    echo -e "${RED}Error: API key is not set.${NC}"
    echo "Please edit this script and set your Cortex API key."
    echo "You can get an API key from the Cortex web interface:"
    echo "1. Log in to Cortex at $CORTEX_URL"
    echo "2. Go to 'Users' and select your user"
    echo "3. Click 'Create API Key'"
    echo "4. Copy the generated API key and set it in this script"
    exit 1
fi

# Check if Cortex is running
echo -e "${YELLOW}Checking if Cortex is running...${NC}"
if curl -s "$CORTEX_URL/api/status" > /dev/null; then
    echo -e "${GREEN}Cortex is running.${NC}"
else
    echo -e "${RED}Error: Cannot connect to Cortex at $CORTEX_URL${NC}"
    echo "Please make sure Cortex is running and accessible."
    exit 1
fi

# Check if the Vulners_CVE analyzer is available
echo -e "${YELLOW}Checking if Vulners_CVE analyzer is available...${NC}"
ANALYZERS=$(curl -s -H "Authorization: Bearer $API_KEY" "$CORTEX_URL/api/analyzer")
if echo "$ANALYZERS" | grep -q "Vulners_CVE"; then
    echo -e "${GREEN}Vulners_CVE analyzer is available.${NC}"
else
    echo -e "${RED}Error: Vulners_CVE analyzer is not available.${NC}"
    echo "Please make sure the analyzer is properly installed and enabled in Cortex."
    echo "You can check the analyzers page in the Cortex web interface."
    exit 1
fi

# Run the analysis
echo -e "${YELLOW}Running analysis for $CVE_ID...${NC}"
RESPONSE=$(curl -s -H "Authorization: Bearer $API_KEY" \
     -H "Content-Type: application/json" \
     -XPOST \
     -d "{\"data\":\"$CVE_ID\", \"dataType\":\"cve\", \"tlp\":2}" \
     "$CORTEX_URL/api/analyzer/Vulners_CVE/run")

# Check if the analysis was submitted successfully
if echo "$RESPONSE" | grep -q "jobId"; then
    JOB_ID=$(echo "$RESPONSE" | grep -o '"jobId":"[^"]*"' | cut -d'"' -f4)
    echo -e "${GREEN}Analysis submitted successfully. Job ID: $JOB_ID${NC}"
else
    echo -e "${RED}Error: Failed to submit analysis.${NC}"
    echo "Response: $RESPONSE"
    exit 1
fi

# Wait for the analysis to complete
echo -e "${YELLOW}Waiting for analysis to complete...${NC}"
STATUS="InProgress"
while [ "$STATUS" = "InProgress" ] || [ "$STATUS" = "Waiting" ]; do
    sleep 2
    JOB_STATUS=$(curl -s -H "Authorization: Bearer $API_KEY" "$CORTEX_URL/api/job/$JOB_ID")
    STATUS=$(echo "$JOB_STATUS" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    echo -n "."
done
echo ""

# Check if the analysis completed successfully
if [ "$STATUS" = "Success" ]; then
    echo -e "${GREEN}Analysis completed successfully.${NC}"
    
    # Get the analysis report
    echo -e "${YELLOW}Retrieving analysis report...${NC}"
    REPORT=$(curl -s -H "Authorization: Bearer $API_KEY" "$CORTEX_URL/api/job/$JOB_ID/report")
    
    # Display a summary of the report
    echo -e "${GREEN}Analysis Report Summary:${NC}"
    echo "==============================="
    
    # Extract and display CVSS score if available
    CVSS_SCORE=$(echo "$REPORT" | grep -o '"score":[^,}]*' | cut -d':' -f2)
    if [ ! -z "$CVSS_SCORE" ]; then
        echo -e "CVSS Score: ${YELLOW}$CVSS_SCORE${NC}"
    fi
    
    # Extract and display vulnerability status if available
    VULN_STATUS=$(echo "$REPORT" | grep -o '"vulnStatus":"[^"]*"' | cut -d'"' -f4)
    if [ ! -z "$VULN_STATUS" ]; then
        echo -e "Vulnerability Status: ${YELLOW}$VULN_STATUS${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Full report is available at:${NC}"
    echo "$CORTEX_URL/api/job/$JOB_ID/report"
    
    echo ""
    echo -e "${GREEN}You can also view the report in the Cortex web interface:${NC}"
    echo "$CORTEX_URL/#/jobs/$JOB_ID"
else
    echo -e "${RED}Analysis failed with status: $STATUS${NC}"
    echo "Please check the job details in the Cortex web interface for more information."
    echo "$CORTEX_URL/#/jobs/$JOB_ID"
fi