from vulners import VulnersApi
import os
import json

# Replace with your actual API key or use environment variable
API_KEY = "G0L3TBKKJ4MH1CSAY69Q65O4EZKB486KKN0CBCWSX73HNSKKDRD585JU2R0BNOHK"

# Instantiate the Vulners client
vulners_client = VulnersApi(api_key=API_KEY)

# Query a CVE
cve_id = "CVE-2021-44228"  # Log4Shell vulnerability

try:
    result = vulners_client.search.get_bulletin(cve_id)
    print(json.dumps(result, indent=2))
except Exception as e:
    print(f"Error: {e}")
