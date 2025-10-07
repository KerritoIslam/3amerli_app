<#
Simple script to create a GitHub issue from a local ISSUE file.
Usage (PowerShell):

# Temporarily set your token in the session (recommended):
$env:GITHUB_TOKEN = 'ghp_xxx'
$env:GITHUB_REPO = 'KerritoIslam/3amerli_app'  # optional, defaults to this repo
.\scripts\create_github_issue.ps1 -Path 'ISSUES/auth-keyboard-overflow.md'

Notes:
- Make sure your token has `repo` scope for private repos, or `public_repo` for public repos.
- The script will print the created issue URL on success.
#>
param(
    [string]$Path = 'ISSUES/auth-keyboard-overflow.md'
)

if (-not (Test-Path -Path $Path)) {
    Write-Error "Issue file not found: $Path"
    exit 2
}

$token = $env:GITHUB_TOKEN
if (-not $token) {
    Write-Error "GITHUB_TOKEN environment variable not set. Please set it and re-run."
    exit 3
}

$repo = $env:GITHUB_REPO -or 'KerritoIslam/3amerli_app'

$content = Get-Content -Raw -Path $Path

# Extract a Title line if present (format: Title: ...)
$title = $null
$body = $content
$match = [regex]::Match($content, '^Title:\s*(.+)\r?\n', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
if ($match.Success) {
    $title = $match.Groups[1].Value.Trim()
    # Remove the Title line from body
    $body = $content.Substring($match.Length).TrimStart()
}

if (-not $title) {
    # fallback to filename
    $title = ([System.IO.Path]::GetFileNameWithoutExtension($Path)).Replace('-', ' ')
}

$payload = @{
    title = $title
    body  = $body
}

# Optionally add labels parsed from the file (looks for a "Labels: " line)
$labelMatch = [regex]::Match($content, '^Labels:\s*(.+)\r?\n', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
if ($labelMatch.Success) {
    $labelsRaw = $labelMatch.Groups[1].Value.Trim()
    if ($labelsRaw.Length -gt 0) {
        $payload.labels = ($labelsRaw -split ',') | ForEach-Object { $_.Trim() }
    }
}

# Prepare headers
$headers = @{
    Authorization = "token $token"
    Accept = 'application/vnd.github+json'
    'User-Agent' = 'create-github-issue-script'
}

$uri = "https://api.github.com/repos/$repo/issues"

try {
    $jsonBody = $payload | ConvertTo-Json -Depth 10
    $resp = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $jsonBody -ContentType 'application/json'
    if ($resp -and $resp.html_url) {
        Write-Host "Issue created: $($resp.html_url)"
        exit 0
    } else {
        Write-Error "Unexpected response from GitHub API: $($resp | Out-String)"
        exit 4
    }
} catch {
    Write-Error "Failed to create issue: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        try { $text = $_.Exception.Response.GetResponseStream() | ForEach-Object { $_ } } catch {}
    }
    exit 5
}
