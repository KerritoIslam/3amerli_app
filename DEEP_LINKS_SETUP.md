# Deep Links Configuration Guide

## Overview

The app supports deep links for payment success and failure callbacks. When the payment gateway completes processing, it redirects users back to the app via these deep links.

## Supported URL Schemes

### 1. Custom Scheme (Recommended for Native Apps)
- **Success**: `amerli://success`
- **Failure**: `amerli://failure`

### 2. HTTPS Universal Links (For Web and App)
- **Success**: `https://amerli.app/payment/success`
- **Failure**: `https://amerli.app/payment/failure`

## Query Parameters

Both success and failure URLs accept the following query parameters:

### Success URL Parameters
| Parameter | Required | Example | Description |
|-----------|----------|---------|-------------|
| `orderId` | No | `123` | Order ID from backend |
| `date` | No | `28/10/2025 15:30` | Payment date and time |
| `paymentMethod` | No | `CIB` | Payment method (CIB, EDAHABIA, CASH) |
| `amount` | No | `1500 DZD` | Total amount paid |
| `invoiceUrl` | No | `https://...` | URL to download invoice |

### Failure URL Parameters
| Parameter | Required | Example | Description |
|-----------|----------|---------|-------------|
| `orderId` | No | `124` | Order ID from backend |
| `date` | No | `28/10/2025 15:35` | Payment attempt date/time |
| `paymentMethod` | No | `EDAHABIA` | Payment method used |
| `amount` | No | `2000 DZD` | Amount that failed |
| `reason` | No | `Payment declined` | Failure reason message |

**Note**: The app also accepts alternative parameter names:
- `payementWay` instead of `paymentMethod`
- `total` instead of `amount`
- `error` instead of `reason`

## Example URLs

### Success Example (Custom Scheme)
```
amerli://success?orderId=123&date=28%2F10%2F2025%2015%3A30&paymentMethod=CIB&amount=1500%20DZD&invoiceUrl=https%3A%2F%2Fexample.com%2Finvoice.pdf
```

### Failure Example (Custom Scheme)
```
amerli://failure?orderId=124&date=28%2F10%2F2025%2015%3A35&paymentMethod=EDAHABIA&amount=2000%20DZD&reason=Payment%20declined%20by%20bank
```

### Success Example (HTTPS)
```
https://amerli.app/payment/success?orderId=125&date=28%2F10%2F2025%2016%3A00&paymentMethod=CIB&amount=3500%20DZD
```

### Failure Example (HTTPS)
```
https://amerli.app/payment/failure?orderId=126&date=28%2F10%2F2025%2016%3A10&paymentMethod=CIB&amount=4000%20DZD&reason=Insufficient%20funds
```

## Testing Deep Links

### Method 1: Use the Test Script (Easiest)
```powershell
# From the app directory
.\test_deeplinks.ps1
```

This interactive script lets you test different deep link scenarios.

### Method 2: ADB Command
```bash
# Test success (custom scheme)
adb shell am start -a android.intent.action.VIEW -d "amerli://success?orderId=123&paymentMethod=CIB&amount=1500%20DZD"

# Test failure (custom scheme)
adb shell am start -a android.intent.action.VIEW -d "amerli://failure?orderId=124&reason=Payment%20declined"

# Test success (HTTPS)
adb shell am start -a android.intent.action.VIEW -d "https://amerli.app/payment/success?orderId=123&paymentMethod=CIB&amount=1500%20DZD"

# Test failure (HTTPS)
adb shell am start -a android.intent.action.VIEW -d "https://amerli.app/payment/failure?orderId=124&reason=Payment%20declined"
```

### Method 3: Browser Test
1. Open Chrome on your Android device
2. Type the deep link URL in the address bar
3. Press Enter - the app should open

### Method 3: HTML Test Page
Create a simple HTML file:
```html
<!DOCTYPE html>
<html>
<body>
  <h1>3amerli Deep Link Test</h1>
  <p>Custom Scheme (amerli://):</p>
  <a href="amerli://success?orderId=123&paymentMethod=CIB&amount=1500">Test Success</a><br>
  <a href="amerli://failure?orderId=124&reason=Test">Test Failure</a>
  
  <p>HTTPS Universal Links:</p>
  <a href="https://amerli.app/payment/success?orderId=125&paymentMethod=CIB&amount=1500">Test HTTPS Success</a><br>
  <a href="https://amerli.app/payment/failure?orderId=126&reason=Test">Test HTTPS Failure</a>
</body>
</html>
```

## Configuring Chargily Payment Gateway

When creating a checkout with Chargily, configure the redirect URLs:

```javascript
// Backend code example (Node.js/NestJS)
const checkout = await chargily.createCheckout({
  // ... other checkout details
  
  // Option 1: Use custom scheme (recommended - more reliable)
  success_url: 'amerli://success?orderId={{ORDER_ID}}&paymentMethod={{PAYMENT_METHOD}}&amount={{AMOUNT}}',
  failure_url: 'amerli://failure?orderId={{ORDER_ID}}&reason={{ERROR_MESSAGE}}',
  
  // Option 2: Use HTTPS universal links (requires domain verification)
  // success_url: 'https://amerli.app/payment/success?orderId={{ORDER_ID}}&paymentMethod={{PAYMENT_METHOD}}&amount={{AMOUNT}}',
  // failure_url: 'https://amerli.app/payment/failure?orderId={{ORDER_ID}}&reason={{ERROR_MESSAGE}}',
});
```

**Important**: Make sure to URL-encode the query parameter values, especially:
- Spaces → `%20`
- Forward slash `/` → `%2F`
- Colon `:` → `%3A`

## How It Works

1. **User completes payment** in WebView (Chargily payment page)
2. **Chargily redirects** to success/failure URL with parameters
3. **Android system** intercepts the URL and opens the app
4. **go_router** automatically navigates to `/payment/success` or `/payment/failure`
5. **Success/Failure page** displays with order details

## Architecture

### Android Configuration
- Intent filters configured in `AndroidManifest.xml`
- Supports both `autoVerify="true"` (HTTPS) and custom scheme

### Router Configuration
- Routes defined in `lib/core/config/router.dart`
- Payment routes are non-protected (accessible without authentication)
- Query parameters extracted via `state.uri.queryParameters`

### Navigation Flow
```
Payment Gateway → Deep Link → Android Intent → App Launch → go_router → Success/Failure Page
```

## iOS Configuration (TODO)

To support iOS deep links, update `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>amerli</string>
    </array>
    <key>CFBundleURLName</key>
    <string>app.amerli</string>
  </dict>
</array>

<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:amerli.app</string>
</array>
```

## Troubleshooting

### Deep link not opening the app
1. **Rebuild the app** after modifying AndroidManifest.xml
2. **Verify ADB connection**: `adb devices`
3. **Check logs**: `adb logcat | grep -i intent`
4. **Test with custom scheme first** (`amerli://`) before HTTPS

### App opens but wrong page shows
1. **Check router logs** in console
2. **Verify query parameters** are URL-encoded
3. **Ensure non-protected routes** include `/payment/success` and `/payment/failure`

### Universal links not working (HTTPS)
1. **Verify domain ownership** with `android:autoVerify="true"`
2. **Add `.well-known/assetlinks.json`** to your website
3. **Use custom scheme** (`amerli://`) as fallback

## Security Notes

- Deep link routes are **non-protected** (accessible without login)
- This is intentional so payment callbacks work even if user isn't authenticated
- Order details are passed via query parameters (consider using order ID only and fetch details from backend)
- For production, validate the order ID on the backend before displaying sensitive information

## Support

For issues or questions:
- Check console logs for routing errors
- Use the test script to verify deep links work
- Ensure payment gateway is configured with correct redirect URLs
