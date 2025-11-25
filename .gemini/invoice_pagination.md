# Invoice Pagination Implementation

## Overview
Implemented pagination for the invoices page to handle the new paginated API response from the backend.

## API Response Structure
The backend now returns a paginated response:
```json
{
  "meta": {
    "total": 19,
    "page": 1,
    "limit": 10,
    "hasNextPage": true,
    "totalPages": 2
  },
  "data": [
    {
      "id": 45,
      "createdAt": "2025-11-23T20:07:09.659Z",
      "pdfUrl": "http://..."
    },
    ...
  ]
}
```

## Changes Made

### 1. Added Pagination State Variables
**File**: `lib/features/profile/app/pages/invoices_page.dart`

Added state variables to track pagination:
- `_currentPage` - Current page number
- `_hasNextPage` - Whether there are more pages to load
- `_isLoadingMore` - Loading state for "load more" operation
- `_scrollController` - ScrollController for infinite scroll

### 2. Updated _fetchInvoices Method
Enhanced the method to:
- Accept a `loadMore` parameter to differentiate between initial load and loading more
- Parse the new API response structure with `meta` and `data` fields
- Extract pagination metadata (`hasNextPage`, `page`)
- Send `page` and `limit` query parameters to the API
- Append items when loading more, or replace when initial load

### 3. Added Infinite Scroll
Implemented scroll detection:
- Added `_onScroll` listener that triggers when user scrolls near the bottom (200px from end)
- Automatically loads more invoices when scrolling down
- Only loads if not already loading and there are more pages

### 4. Updated UI
- Wrapped ListView in a Column to allow for loading indicator
- Added ScrollController to ListView
- Shows CircularProgressIndicator at bottom when loading more invoices
- Maintains the existing UI structure and styling

## Features

### ✅ Infinite Scroll
- Automatically loads more invoices as user scrolls down
- No manual "load more" button needed
- Smooth user experience

### ✅ Loading States
- Initial loading: Shows centered spinner
- Loading more: Shows small spinner at bottom of list
- Prevents duplicate requests while loading

### ✅ Pagination Tracking
- Tracks current page number
- Respects `hasNextPage` flag from API
- Stops loading when all pages are fetched

### ✅ Error Handling
- Maintains existing error handling with TopToast
- Gracefully handles pagination errors

## Usage

The pagination works automatically:
1. **Initial Load**: Fetches page 1 with 10 items
2. **Scroll Down**: When user scrolls near bottom, automatically fetches next page
3. **Append Data**: New invoices are added to the end of the list
4. **Stop Loading**: Stops when `hasNextPage` is false

## API Calls

Initial request:
```
GET /invoices/user/?page=1&limit=10
```

Subsequent requests:
```
GET /invoices/user/?page=2&limit=10
GET /invoices/user/?page=3&limit=10
...
```

## Testing

To test the implementation:
1. Navigate to the invoices page
2. Scroll down to the bottom of the list
3. Verify that a loading indicator appears
4. Verify that more invoices are loaded
5. Continue scrolling to load all pages
6. Verify loading stops when all invoices are fetched
