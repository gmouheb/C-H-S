# Testing the Vulners_CVE Analyzer with CURL

This guide explains how to test the Vulners_CVE analyzer using CURL commands to ensure it's working correctly.

## Prerequisites

1. Cortex is installed and running (typically on port 9001)
2. The Vulners_CVE analyzer is installed and enabled in Cortex
3. You have a Vulners API key
4. You have a Cortex API key

## Setup Options

There are two ways to set up the Vulners_CVE analyzer:

### Option 1: Using the provided docker-compose.yml

1. Navigate to the Vulners directory:
   ```bash
   cd Vulners
   ```

2. Set your Vulners API key as an environment variable:
   ```bash
   export VULNERS_API_KEY="your-vulners-api-key"
   ```

3. Start the services:
   ```bash
   docker-compose up -d
   ```

### Option 2: Adding the analyzer to an existing Cortex installation

1. Make sure your Cortex installation is running (using docker-compose-cortex.yaml)

2. Build and run the Vulners_CVE analyzer:
   ```bash
   cd Vulners
   docker build -t vulners_cve ./Vulners_CVE
   docker run -d --name vulners_analyzer \
     -e VULNERS_API_KEY="your-vulners-api-key" \
     -v /tmp/cortex-jobs:/tmp/cortex-jobs \
     --network SOC_NET \
     vulners_cve
   ```

   Note: Make sure to use the same network as your Cortex installation (SOC_NET in this example).

## Registering the Analyzer in Cortex

1. Access the Cortex web interface at `http://localhost:9001`
2. Log in with your account
3. Go to the "Analyzers" page
4. Click on "Refresh analyzers" to detect the Vulners_CVE analyzer
5. Find "Vulners_CVE" in the list and enable it
6. Configure the analyzer with your Vulners API key if you didn't set it as an environment variable

## Getting a Cortex API Key

1. Log in to the Cortex web interface
2. Go to "Users" and select your user
3. Click "Create API Key"
4. Copy the generated API key

## Testing with the Script

We've provided a script to easily test the Vulners_CVE analyzer:

1. Edit the script to add your Cortex API key:
   ```bash
   nano test_vulners_cve.sh
   ```
   
   Update the `API_KEY` variable with your Cortex API key.

2. Make the script executable:
   ```bash
   chmod +x test_vulners_cve.sh
   ```

3. Run the script:
   ```bash
   ./test_vulners_cve.sh
   ```

   By default, the script tests with CVE-2021-44228 (Log4Shell). You can modify the `CVE_ID` variable in the script to test with a different CVE.

## Testing Manually with CURL

If you prefer to test manually with CURL commands:

1. Run an analysis:
   ```bash
   curl -H "Authorization: Bearer YOUR_API_KEY" \
        -H "Content-Type: application/json" \
        -XPOST \
        -d '{"data":"CVE-2021-44228", "dataType":"cve", "tlp":2}' \
        http://localhost:9001/api/analyzer/Vulners_CVE/run
   ```

   Replace `YOUR_API_KEY` with your Cortex API key.

2. Get the results (replace `JOB_ID` with the job ID returned from the previous command):
   ```bash
   curl -H "Authorization: Bearer YOUR_API_KEY" \
        http://localhost:9001/api/job/JOB_ID/report
   ```

## Troubleshooting

If you encounter issues:

1. **Analyzer not found**: Make sure the analyzer is properly installed and enabled in Cortex.

2. **Authentication errors**: Check that your Vulners API key and Cortex API key are correct.

3. **Connection issues**: Ensure that the analyzer container is on the same network as Cortex.

4. **Analysis fails**: Check the Cortex logs for more details:
   ```bash
   docker logs cortex.local
   ```

5. **API key issues**: Verify that you're using the correct API key format in your CURL commands.

## Example Output

A successful analysis should return information about the CVE, including:

- CVSS score
- Vulnerability status
- Detailed information about the vulnerability
- References and related information

You can view the full report in the Cortex web interface or via the API.