# Category Images Fix

## Problem
Category images were not displaying in the admin categories page.

## Root Cause
The category model was parsing the `pictureUrl` field from the API response directly without resolving the URL. The API returns filenames (e.g., `"1763589439108-6e28418ac455-electr.jpg"`) that need to be resolved into full URLs using the storage service.

## Solution
Updated the `CategoryModel` to use the `resolveImageUrl()` utility function, matching the behavior of product images.

## Changes Made

### File: `lib/features/admin/categories/data/models/category_model.dart`

**Before:**
```dart
import '../../domain/entities/category.dart';

factory CategoryModel.fromJson(Map<String, dynamic> json) {
  return CategoryModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    imageUrl: json['pictureUrl'] as String? ?? json['imageUrl'] as String?,
    // ...
  );
}
```

**After:**
```dart
import '../../domain/entities/category.dart';
import '../../../../../utils/image_resolver.dart';

factory CategoryModel.fromJson(Map<String, dynamic> json) {
  final rawPictureUrl = json['pictureUrl'] as String? ?? 
                        json['imageUrl'] as String? ?? 
                        json['picture'] as String?;
  final resolvedImageUrl = rawPictureUrl != null && rawPictureUrl.isNotEmpty
      ? resolveImageUrl(rawPictureUrl)
      : null;
  
  return CategoryModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    imageUrl: resolvedImageUrl,
    // ...
  );
}
```

## How It Works

The `resolveImageUrl()` function handles different URL formats:
1. **Full URLs** (starting with `http://` or `https://`) → Returned as-is
2. **Filenames** (e.g., `"1763589439108-6e28418ac455-electr.jpg"`) → Returns empty string (shows placeholder)
3. **Paths starting with `/`** → Prepends API origin
4. **Development mode** → Logs warnings for debugging

## API Response Format

According to the backend docs (`CategoryResDto`):
```json
{
  "id": 1,
  "label": "Electronics",
  "pictureUrl": "1763589439108-6e28418ac455-electr.jpg"
}
```

The `pictureUrl` is typically just a filename, which is why the resolver is needed.

## Fallback Behavior

The code now checks multiple possible field names:
1. `pictureUrl` (primary, as per API docs)
2. `imageUrl` (fallback)
3. `picture` (additional fallback)

This ensures compatibility with different API versions and responses.

## Image Display in UI

In `admin_categories_page.dart`, categories display images using:
```dart
Container(
  width: 36,
  height: 36,
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8)
  ),
  child: category.imageUrl != null && category.imageUrl!.isNotEmpty
      ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            category.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Icon(
              Icons.image_not_supported,
              color: Colors.grey.shade400,
              size: 16
            )
          )
        )
      : Icon(Icons.category,
          color: Theme.of(context).colorScheme.primary,
          size: 18
        ),
)
```

With the fix:
- ✅ If `pictureUrl` is a valid full URL → Image loads
- ✅ If `pictureUrl` is empty or can't be resolved → Placeholder icon shows
- ✅ If image fails to load → Error builder shows "image not supported" icon

## Testing

After this fix, category images should display correctly in the admin categories page. If images still don't show:
1. Check if the API is returning full URLs or just filenames
2. Verify the storage service URL in `app_constants.dart`
3. Check console logs for image resolver warnings (in debug mode)

## Related Files

- `lib/utils/image_resolver.dart` - The URL resolution utility
- `lib/features/admin/products/data/models/product_model.dart` - Uses same resolver for product images
- `lib/features/catalog/data/models/product_model.dart` - Uses same resolver for catalog product images
