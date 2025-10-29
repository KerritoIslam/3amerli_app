# Test Deep Links for 3amerli App
# Make sure your Android device/emulator is connected via ADB

Write-Host "=== 3amerli Deep Link Tester ===" -ForegroundColor Cyan
Write-Host ""

# Check if adb is available
$adbPath = (Get-Command adb -ErrorAction SilentlyContinue).Source
if (-not $adbPath) {
    Write-Host "ERROR: adb command not found. Make sure Android SDK is installed and in PATH." -ForegroundColor Red
    exit 1
}

# Check if device is connected
$devices = adb devices
if ($devices -match "device$") {
    Write-Host "✓ Device connected" -ForegroundColor Green
} else {
    Write-Host "ERROR: No Android device/emulator connected" -ForegroundColor Red
    Write-Host "Run 'adb devices' to check connection" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Select a deep link to test:" -ForegroundColor Yellow
Write-Host "1. Payment Success (custom scheme: amerli://)"
Write-Host "2. Payment Failure (custom scheme: amerli://)"
Write-Host "3. Payment Success (HTTPS: https://amerli.app)"
Write-Host "4. Payment Failure (HTTPS: https://amerli.app)"
Write-Host "5. Custom URL (enter manually)"
Write-Host ""

$choice = Read-Host "Enter choice (1-5)"

switch ($choice) {
    "1" {
        $url = "amerli://success?orderId=123&date=28/10/2025%2015:30&paymentMethod=CIB&amount=1500%20DZD&invoiceUrl=https://example.com/invoice.pdf"
        Write-Host "Testing: $url" -ForegroundColor Cyan
        adb shell am start -a android.intent.action.VIEW -d "$url"
    }
    "2" {
        $url = "amerli://failure?orderId=124&date=28/10/2025%2015:35&paymentMethod=EDAHABIA&amount=2000%20DZD&reason=Payment%20declined%20by%20bank"
        Write-Host "Testing: $url" -ForegroundColor Cyan
        adb shell am start -a android.intent.action.VIEW -d "$url"
    }
    "3" {
        $url = "https://amerli.app/payment/success?orderId=125&date=28/10/2025%2016:00&paymentMethod=CIB&amount=3500%20DZD"
        Write-Host "Testing: $url" -ForegroundColor Cyan
        adb shell am start -a android.intent.action.VIEW -d "$url"
    }
    "4" {
        $url = "https://amerli.app/payment/failure?orderId=126&date=28/10/2025%2016:10&paymentMethod=CIB&amount=4000%20DZD&reason=Insufficient%20funds"
        Write-Host "Testing: $url" -ForegroundColor Cyan
        adb shell am start -a android.intent.action.VIEW -d "$url"
    }
    "5" {
        $url = Read-Host "Enter custom URL"
        Write-Host "Testing: $url" -ForegroundColor Cyan
        adb shell am start -a android.intent.action.VIEW -d "$url"
    }
    default {
        Write-Host "Invalid choice" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "✓ Deep link sent to device!" -ForegroundColor Green
Write-Host "Check your app to see if it opened the correct page." -ForegroundColor Yellow
