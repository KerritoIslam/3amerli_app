# Product Model Updates - Pictures with IDs

## Summary
Updated the product models and repository to handle the new API response format where pictures now include both URL and ID fields.

## Changes Made

### 1. Catalog Product Model (`lib/features/catalog/data/models/product_model.dart`)

**Added:**
- `pictureIds` field to store picture IDs (nullable)
- Support for parsing new API format: `{"url": "...", "id": 123}`
- Backward compatibility with old string array format

**Key Updates:**
- `fromJson`: Now handles both object format `{url, id}` and string array format
- Extracts and stores picture IDs separately when available
- Falls back gracefully for endpoints that still return string arrays

### 2. Admin Product Model (`lib/features/admin/products/data/models/product_model.dart`)

**Added:**
- `pictureIds` field to store picture IDs (nullable)
- Enhanced image parsing to extract IDs from new format
- Backward compatibility maintained

**Key Updates:**
- `fromJson`: Parses both new object format and old string format
- `fromEntity`: Preserves picture IDs when converting from entity

### 3. Admin Products Repository (`lib/features/admin/products/data/repositories/admin_products_repository_impl.dart`)

**Enhanced Product Update:**
- `updateProduct`: Now compares current and new picture IDs
- Automatically detects which pictures were removed
- Sends `picturesToDelete` array with IDs to delete

**Updated:**
- `_createProductFormData`: Added `picturesToDelete` parameter
- Includes picture IDs to delete in the form data when updating

## API Compatibility

### New Format (GET /api/v1/products/{id})
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

### Old Format (Still Supported)
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

### Product Update (PUT /api/v1/products/{id})
The update operation now supports the `picturesToDelete` field:
```
FormData:
  - name: "Product Name"
  - description: "..."
  - price: 100
  - picturesToDelete: [53, 54]  // IDs of pictures to delete
  - pictures: [new_image_file]   // New images to add
```

## How It Works

1. **Fetching Products**: When products are fetched, the model automatically detects if pictures are in the new format (objects with url/id) or old format (strings) and parses accordingly.

2. **Storing IDs**: Picture IDs are stored in the `pictureIds` field, separate from the URLs in the `pics`/`images` field.

3. **Updating Products**: 
   - The repository fetches the current product to get existing picture IDs
   - Compares with the new product to find removed pictures
   - Sends removed picture IDs in `picturesToDelete` field
   - Uploads new images via `pictures` field

4. **Backward Compatibility**: Endpoints that haven't been updated yet will still work, as the code handles both formats gracefully.

## Testing Recommendations

1. Test fetching products from endpoints that return new format
2. Test fetching products from endpoints that still use old format
3. Test updating a product and removing some pictures
4. Test updating a product and adding new pictures
5. Verify pictures are correctly deleted from the server

## Notes

- The `pictureIds` field is nullable to support endpoints that don't provide IDs
- The parsing logic is defensive and handles missing or malformed data
- Print statements are used for debugging and can be removed or replaced with proper logging later
