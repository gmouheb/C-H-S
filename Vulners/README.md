# Vulners CVE Analyzer for Cortex

This repository contains a Cortex analyzer for querying the Vulners API to retrieve information about CVE IDs.

## Recent Improvements

The Vulners_CVE analyzer has been enhanced with the following features:

- **CVE ID Normalization**: Automatically normalizes CVE IDs by removing spaces and converting to uppercase
- **Format Validation**: Validates that CVE IDs follow the standard format (CVE-YYYY-NNNNN)
- **Improved Error Handling**: Better error messages for invalid formats and when no information is found
- **Detailed Documentation**: Added comprehensive documentation on using the analyzer with CURL

For detailed usage instructions, see the [Vulners_CVE Analyzer README](./Vulners_CVE/README.md).

## Files Structure

```
.
├── docker-compose.yml
└── Vulners_CVE
    ├── Dockerfile
    ├── requirements.txt
    ├── vulners_cve.json
    └── vulners
        └── vulners_analyzer.py
```

## Setup Instructions

### Prerequisites

- Docker and Docker Compose installed
- A Vulners API key (get one from [Vulners](https://vulners.com/))

### Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Set your Vulners API key as an environment variable:
   ```bash
   export VULNERS_API_KEY="your-vulners-api-key"
   ```

3. Start the services using Docker Compose:
   ```bash
   docker-compose up -d
   ```

4. Wait for Cortex to initialize (this may take a few minutes).

### Registering the Analyzer in Cortex

1. Access the Cortex web interface at `http://localhost:9001`.

2. Create an admin account if this is your first time using Cortex.

3. Create an organization and add a user with the `analyze` role.

4. Log in with the user account.

5. Go to the "Analyzers" page.

6. Click on "Refresh analyzers" to detect the new analyzer.

7. Find "Vulners_CVE" in the list and enable it.

8. Configure the analyzer with your Vulners API key if you didn't set it as an environment variable.

### Using the Analyzer via Cortex API

#### Authentication

First, get an API key from Cortex:

1. Log in to the Cortex web interface.
2. Go to "Users" and select your user.
3. Click "Create API Key".
4. Copy the generated API key.

#### Running an Analysis

Use the following curl command to analyze a CVE:

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
     -H "Content-Type: application/json" \
     -XPOST \
     -d '{"data":"CVE-2021-44228", "dataType":"cve", "tlp":2}' \
     http://localhost:9001/api/analyzer/Vulners_CVE/run
```

Replace `YOUR_API_KEY` with your Cortex API key.

#### Getting Analysis Results

To get the results of an analysis:

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
     http://localhost:9001/api/job/JOB_ID/report
```

Replace `JOB_ID` with the job ID returned from the run command.

## Troubleshooting

### Common Issues

1. **AttributeError: module 'vulners' has no attribute 'Vulners'**

   This error occurs when using an older version of the vulners library or importing it incorrectly. The analyzer uses the correct import:
   ```python
   from vulners import VulnersApi
   ```

   Make sure you're using vulners version 3.0.2 or later.

2. **API Key Issues**

   If you encounter authentication errors, check that:
   - Your Vulners API key is correct
   - The environment variable is properly set
   - The API key is correctly passed to the analyzer

3. **Connection Issues**

   If the analyzer can't connect to Cortex:
   - Ensure both services are running (`docker-compose ps`)
   - Check that they're on the same network
   - Verify the shared volume for job files is properly mounted

4. **Analyzer Not Found**

   If Cortex doesn't detect the analyzer:
   - Restart the Cortex service
   - Check the analyzer's JSON configuration file
   - Ensure the analyzer path in the JSON file is correct

### Logs

To check logs for troubleshooting:

```bash
# Cortex logs
docker-compose logs cortex

# Analyzer logs
docker-compose logs vulners_analyzer
```

## License

This project is licensed under the AGPL-V3 License.
