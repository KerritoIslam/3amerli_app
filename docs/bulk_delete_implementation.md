# Bulk Delete Implementation for Products and Users

## Overview
This implementation adds proper bulk delete functionality for products and users in the admin panel, using the backend's dedicated bulk delete API endpoints.

## API Endpoints Used

### Products Bulk Delete
- **Endpoint**: `DELETE /api/v1/products/admin/bulk`
- **Request Body**:
  ```json
  {
    "productIds": [1, 2, 3]
  }
  ```
- **Response**: Success message (200 OK)

### Users Bulk Delete
- **Endpoint**: `DELETE /api/v1/user/admin/bulk`
- **Request Body**:
  ```json
  {
    "userIds": [1, 2, 3]
  }
  ```
- **Response**: Success message with deleted count

## Changes Made

### 1. Products Repository (`admin_products_repository_impl.dart`)
**File**: `lib/features/admin/products/data/repositories/admin_products_repository_impl.dart`

**Updated Method**: `deleteProducts(List<String> ids)`  
- Changed from: Deleting products one by one in a loop
- Changed to: Single bulk delete API call
- Converts String IDs to integers as required by the API
- Uses `apiService.client.delete()` to send DELETE request with body

### 2. Users Repository (`admin_users_repository_impl.dart`)
**File**: `lib/features/admin/users/data/repositories/admin_users_repository_impl.dart`

**Updated Method**: `deleteMultipleUsers(List<String> userIds)`
- Changed from: Incorrect endpoint `/user/delete-multiple` with POST
- Changed to: Correct endpoint `/user/admin/bulk` with DELETE
- Converts String IDs to integers as required by the API
- Uses `apiService.client.delete()` to send DELETE request with body

## Existing UI Integration
Both admin pages already have the UI and event handling in place:

### Admin Products Page
- ✅ Selection checkboxes for products
- ✅ "Delete Selected" button in options menu  
- ✅ Confirmation dialog
- ✅ `AdminProductsDeleteMultipleEvent` event
- ✅ Bloc handler for bulk delete

### Admin Users Page
- ✅ Selection checkboxes for users
- ✅ "Delete Selected" button
- ✅ Confirmation dialog  
- ✅ `AdminUsersDeleteMultipleEvent` event
- ✅ Bloc handler for bulk delete

## Benefits
1. **Performance**: Single API call instead of multiple sequential requests
2. **Reliability**: Atomic operation on the backend
3. **User Experience**: Faster deletion of multiple items
4. **Server Load**: Reduced network overhead

## Testing Recommendations
1. Test selecting and deleting multiple products (2-5 items)
2. Test selecting and deleting multiple users (2-5 items)
3. Verify success messages display correctly
4. Verify the list refreshes after bulk delete
5. Test error handling (network errors, unauthorized, etc.)
6. Test with mixed selections (some items that exist, some that don't)

## Notes
- The implementation uses `apiService.client.delete()` directly because the ApiService wrapper's `delete()` method doesn't support request bodies
- Both implementations properly convert String IDs to integers as required by the backend API
- Error handling is delegated to the existing `_handleError()` methods in each repository
