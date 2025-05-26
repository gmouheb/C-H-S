# Vulners_CVE Analyzer for Cortex

This analyzer queries the Vulners.com API to retrieve detailed information about CVE IDs.

## Features

- Retrieves comprehensive vulnerability information for CVE IDs
- Provides CVSS scores and vulnerability status
- Normalizes and validates CVE ID format
- Handles error cases gracefully

## Requirements

- Vulners API key (get one from [Vulners](https://vulners.com/))
- Cortex instance

## Configuration

The analyzer can be configured in two ways:

1. **Environment Variable**: Set the `VULNERS_API_KEY` environment variable
2. **Cortex Configuration**: Configure the API key in the Cortex web interface

## Usage with CURL

To use the analyzer with CURL, you need to:

1. Get a Cortex API key from the Cortex web interface
2. Format your request properly

### Example CURL Request

```bash
curl -H "Authorization: Bearer YOUR_CORTEX_API_KEY" \
     -H "Content-Type: application/json" \
     -XPOST \
     -d '{"data":"CVE-2021-44228", "dataType":"cve", "tlp":2}' \
     http://your-cortex-instance:9001/api/analyzer/Vulners_CVE/run
```

Replace:
- `YOUR_CORTEX_API_KEY` with your Cortex API key
- `your-cortex-instance` with your Cortex hostname or IP address

### Request Format

The request must include:

- `data`: The CVE ID (e.g., "CVE-2021-44228")
- `dataType`: Must be "cve"
- `tlp`: Traffic Light Protocol level (0-3)

### CVE ID Format

The analyzer now includes normalization and validation for CVE IDs:

- Spaces are removed
- Input is converted to uppercase
- The format must match the pattern: CVE-YYYY-NNNNN

Examples of valid inputs:
- "CVE-2021-44228"
- "cve-2021-44228"
- "CVE 2021 44228"

### Response Format

A successful response will include:

- Job ID for retrieving the results
- Status of the job

### Retrieving Results

To get the analysis results:

```bash
curl -H "Authorization: Bearer YOUR_CORTEX_API_KEY" \
     http://your-cortex-instance:9001/api/job/JOB_ID/report
```

Replace `JOB_ID` with the job ID from the run response.

## Error Handling

The analyzer now includes improved error handling:

1. **Invalid CVE ID Format**: Returns an error if the CVE ID doesn't match the expected format
2. **No Information Found**: Returns an error if the Vulners API doesn't have information about the CVE
3. **API Errors**: Provides detailed error messages for API-related issues

## Troubleshooting

If you encounter issues:

1. **Check API Keys**: Verify both your Vulners API key and Cortex API key
2. **Check CVE ID Format**: Ensure the CVE ID follows the standard format
3. **Check Connectivity**: Ensure the analyzer can connect to the Vulners API
4. **Check Logs**: Review the Cortex logs for detailed error messages