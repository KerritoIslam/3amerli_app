# Issue 5: Product Details Favorite Button & Catalog Refresh

## Requirements
1. Set favorite button state in product details AppBar according to `isLoved` from API response
2. Display loved count from API response
3. Refresh catalog when product details page is disposed

## Current Implementation Analysis Needed

### Step 1: Check Product Details Page
- File: `lib/features/catalog/app/pages/product_details_page.dart`
- Need to find:
  - How product data is fetched
  - Where favorite button is defined
  - Current favorite state management
  - Whether `isLoved` and `lovedCount` are in response

### Step 2: Check Product Entity/Model
- Verify `isLoved` field exists in Product entity
- Verify `lovedCount` field exists
- If missing, add these fields

### Step 3: Implement Favorite State from API
- Initialize favorite button with `product.isLoved` value
- Display `product.lovedCount` in UI
- Update both when user toggles favorite

### Step 4: Add Catalog Refresh on Dispose
- Add dispose lifecycle method to product details page
- Trigger CatalogBloc refresh event
- Ensure it only refreshes if page was actually used (not on back press during loading)

## Implementation Plan

### Changes Required

#### 1. Product Entity (if fields missing)
```dart
// lib/features/catalog/domain/entities/product.dart
class Product {
  // ... existing fields
  final bool isLoved;
  final int lovedCount;
  
  const Product({
    // ... existing params
    this.isLoved = false,
    this.lovedCount = 0,
  });
}
```

#### 2. Product Model (if fields missing)
```dart
// lib/features/catalog/data/models/product_model.dart
factory ProductModel.fromJson(Map<String, dynamic> json) {
  return ProductModel(
    // ... existing fields
    isLoved: json['isLoved'] ?? json['is_loved'] ?? false,
    lovedCount: json['lovedCount'] ?? json['loved_count'] ?? 0,
  );
}
```

#### 3. Product Details Page
```dart
// lib/features/catalog/app/pages/product_details_page.dart

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late bool _isFavorite;
  late int _lovedCount;
  
  @override
  void initState() {
    super.initState();
    // Initialize from product data
    _isFavorite = widget.product.isLoved;
    _lovedCount = widget.product.lovedCount;
  }
  
  @override
  void dispose() {
    // Refresh catalog when leaving product details
    try {
      final catalogBloc = context.read<CatalogBloc>();
      catalogBloc.add(CatalogLoadEvent());
    } catch (e) {
      // CatalogBloc might not be available
    }
    super.dispose();
  }
  
  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
      _lovedCount += _isFavorite ? 1 : -1;
    });
    
    // Call favorites API
    // ... existing favorite toggle logic
  }
  
  // In AppBar actions:
  IconButton(
    icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
    onPressed: _toggleFavorite,
  ),
  
  // Display loved count somewhere in  UI:
  Text('$_lovedCount ${AppLanguage.loves}'),
}
```

## Questions to Verify

1. Does the product API response include `isLoved` and `lovedCount` fields?
2. Are these fields already in the Product entity/model?
3. Where exactly should the loved count be displayed in the UI?
4. Should catalog refresh happen on every dispose or only after favorite changes?

## Testing

- [ ] Navigate to product details
- [ ]Verify favorite button shows correct initial state (filled if loved, outline if not)
- [ ] Verify loved count displays correct number
- [ ] Toggle favorite
- [ ] Verify count increments/decrements
- [ ] Verify button state updates
- [ ] Go back to catalog
- [ ] Verify catalog refreshes
- [ ] Check that product's favorite state persists correctly
