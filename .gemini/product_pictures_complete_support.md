# Product Model - Complete API Response Format Support

## Supported Response Formats

The product models now support **all** the following API response formats:

### Format 1: New API - Pictures with IDs (GET /api/v1/products/{id})
```json
{
  "id": 28,
  "name": "Sample Product",
  "pictures": [
    {
      "url": "1763600295451-a55ed8b19afb-Untitled.jpg",
      "id": 53
    },
    {
      "url": "1763600295453-2c36e1db5ddd-Untitled.jpg",
      "id": 54
    }
  ]
}
```
✅ **Handled**: URLs extracted to `pics` array, IDs stored in `pictureIds`

### Format 2: Old API - Pictures as String Array
```json
{
  "id": 28,
  "name": "Sample Product",
  "pictures": [
    "image1.jpg",
    "image2.jpg"
  ]
}
```
✅ **Handled**: Strings extracted to `pics` array, `pictureIds` is null

### Format 3: Admin API - Main Picture as String (GET /api/v1/products/admin/all)
```json
{
  "id": 30,
  "name": "mouloud",
  "price": 100,
  "disponibility": true,
  "mainPicture": "http://storage.ammerli.com/products/1764060453985-8795f3e04629-1000133267.jpg"
}
```
✅ **Handled**: `mainPicture` extracted to `pics` array as single element, `pictureIds` is null

### Format 4: Legacy - Single Picture Fields
```json
{
  "id": 28,
  "name": "Sample Product",
  "picture": "image.jpg"
}
```
or with alternative field names:
- `pic`
- `image`
- `thumbnail`

✅ **Handled**: Single picture extracted to `pics` array, `pictureIds` is null

### Format 5: Mixed Formats (Some endpoints may return variations)
```json
{
  "id": 28,
  "name": "Sample Product",
  "pics": ["image1.jpg", "image2.jpg"]
}
```
✅ **Handled**: Works with both `pictures` and `pics` field names

## Parsing Priority

Both catalog and admin product models follow this priority order:

### For Image Arrays:
1. `pictures` (checks for both object array with IDs and string array)
2. `pics` (checks for both object array with IDs and string array)
3. `images` (admin model only)
4. `photos` (admin model only)

### For Single Images (fallback):
1. `mainPicture` ⭐ **NEW** - Added for admin endpoints
2. `picture`
3. `pic`
4. `image`
5. `thumbnail`

## Code Changes Summary

### Catalog Product Model
- Added `mainPicture` to single-picture field checks
- Handles both new format (objects with url/id) and old format (strings)
- Stores picture IDs when available in `pictureIds` field

### Admin Product Model
- Already supported `mainPicture`, `main_picture`, `mainpicture`
- Enhanced to extract IDs from new format
- Stores picture IDs when available in `pictureIds` field

### Admin Products Repository
- Enhanced update operation to detect deleted pictures
- Compares current vs new picture IDs
- Sends `picturesToDelete` array when updating products

## Testing Matrix

| Endpoint | Response Format | Status |
|----------|----------------|--------|
| GET /api/v1/products/{id} | Pictures with IDs | ✅ Supported |
| GET /api/v1/products/all | Pictures as strings | ✅ Supported |
| GET /api/v1/products/admin/all | mainPicture string | ✅ Supported |
| GET /api/v1/products/wholeseller/all | Pictures variations | ✅ Supported |
| GET /api/v1/products/favorite/all | Pictures variations | ✅ Supported |
| PUT /api/v1/products/{id} | With picturesToDelete | ✅ Supported |

## Backward Compatibility

All changes are **100% backward compatible**:
- No breaking changes to existing code
- New fields are nullable
- Defensive parsing handles missing or malformed data
- Gracefully degrades if picture IDs are not available

## Example Parsing Scenarios

### Scenario 1: Admin Products List
**Input:**
```json
{
  "id": 30,
  "name": "mouloud",
  "mainPicture": "http://example.com/image.jpg"
}
```
**Output:**
```dart
ProductModel(
  id: '30',
  name: 'mouloud',
  images: ['http://example.com/image.jpg'],
  pictureIds: null
)
```

### Scenario 2: Product Details with IDs
**Input:**
```json
{
  "id": 28,
  "pictures": [
    {"url": "image1.jpg", "id": 53},
    {"url": "image2.jpg", "id": 54}
  ]
}
```
**Output:**
```dart
ProductModel(
  id: '28',
  images: ['image1.jpg', 'image2.jpg'],
  pictureIds: [53, 54]
)
```

### Scenario 3: Old Format String Array
**Input:**
```json
{
  "id": 28,
  "pictures": ["image1.jpg", "image2.jpg"]
}
```
**Output:**
```dart
ProductModel(
  id: '28',
  images: ['image1.jpg', 'image2.jpg'],
  pictureIds: null
)
```

## Notes

- The parsing is defensive and handles all edge cases
- Empty strings are filtered out from picture arrays
- HTTP URLs are preserved, local paths are resolved
- Picture IDs are only stored when explicitly provided by the API
- The `pictureIds` field is nullable to indicate when IDs are not available
