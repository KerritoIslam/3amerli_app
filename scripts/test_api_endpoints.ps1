param(
    [string]$BaseUrl = "http://localhost/api/v1",
    [string]$Token = $null
)

# Usage examples:
# .\test_api_endpoints.ps1 -BaseUrl "http://192.168.11.70/api/v1" -Token "ey..."
# Or rely on AppConstants.apiBaseUrl and pass Token only.

$logDir = Join-Path -Path $PSScriptRoot -ChildPath "logs"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }
$logFile = Join-Path -Path $logDir -ChildPath ("api_test_{0:yyyyMMdd_HHmmss}.log" -f (Get-Date))

function Log($msg) {
    $ts = (Get-Date).ToString('o')
    $line = "[$ts] $msg"
    $line | Tee-Object -FilePath $logFile -Append
}

function Invoke-Api($method, $path, $body=$null, $headers=@{}) {
    $url = "$BaseUrl$path"
    Log("REQUEST $method $url body=$($body -as [string]) headers=$($headers.keys -join ',')")
    try {
        if ($Token -and -not $headers.ContainsKey('Authorization')) {
            $headers['Authorization'] = "Bearer $Token"
        }

        $result = Invoke-RestMethod -Method $method -Uri $url -Headers $headers -Body ($body | ConvertTo-Json -Depth 6) -ContentType 'application/json'
        Log("RESPONSE $method $url -> 200 OK : $([string](ConvertTo-Json $result -Depth 6))")
        return @{ success = $true; data = $result }
    } catch {
        $err = $_.Exception
        if ($err.Response) {
            $status = $err.Response.StatusCode.value__
            $content = $err.Response.Content | Out-String
            Log("RESPONSE $method $url -> $status : $content")
            return @{ success = $false; status = $status; body = $content }
        } else {
            Log("NETWORK ERROR: $err.Message")
            return @{ success = $false; status = 0; body = $err.Message }
        }
    }
}

Log("Starting API smoke tests against $BaseUrl")

# 1) Send OTP (replace with a test number your backend accepts)
Invoke-Api -method 'POST' -path '/authentication/otp/send' -body @{ phoneNumber = '+213560620999' }

# 2) Validate OTP (this will likely fail unless OTP is correct; used to test structure)
Invoke-Api -method 'POST' -path '/authentication/otp/validate' -body @{ phoneNumber = '+213560620999'; otp = '123456' }

# 3) Try refresh (requires a refresh token) — pass via -Token parameter as refresh token in header
Invoke-Api -method 'POST' -path '/authentication/refresh' -headers @{ Authorization = "Bearer $Token" }

# 4) Get current user (requires valid access token)
Invoke-Api -method 'GET' -path '/user/me'

# 5) Get products with pagination
Invoke-Api -method 'GET' -path '/products/all?page=1&limit=5'

Log('API smoke tests finished. Review the log file: ' + $logFile)

Write-Output "Log saved to: $logFile"
