API tester

This tool runs automated tests against the backend OpenAPI spec and writes a detailed JSON report.

Prerequisites
- Python 3.8+
- pip install requests

Usage (PowerShell)

# set base url and optional token
$env:BASE_URL = 'https://6794279c7cb2.ngrok-free.app/'
$env:BEARER_TOKEN = 'your_jwt_here'  # optional
python .\tools\api_tester.py --base-url $env:BASE_URL --token $env:BEARER_TOKEN

Output
- A JSON report is written to `reports/api_test_report_<timestamp>.json` containing:
  - base_url, timestamp
  - endpoints: list of objects with request/response data
  - summary: total, success, errors, details

Notes
- The script synthesizes minimal example payloads for request bodies based on the OpenAPI schemas. It's a best-effort approach and intended for staging environments.
- Do not run destructive endpoints (DELETE) against production unless you know the consequences.
- If some endpoints require complex auth or multipart uploads with real files, the script will send placeholders. You can modify the generated requests in `tools/api_tester.py` to suit your environment.
