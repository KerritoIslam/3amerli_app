# Toast Message Localization - Required Changes

## Overview
This document lists all hardcoded French/English strings in toast messages that need to be replaced with AppLanguage constants to support multi-language display.

## Files Requiring Changes

### 1. Admin Orders Page
**File**: `lib/features/admin/orders/app/pages/admin_orders_page.dart`

**Line 107**: 
```dart
// Current:
TopToast.show(context, 'Erreur lors de l\'exportation CSV', isError: true);

// Should be:
TopToast.show(context, AppLanguage.csvExportError, isError: true);
```
Note: `AppLanguage.csvExportError` already exists with translations:
- EN: 'Error exporting CSV'
- FR: 'Erreur lors de l\'exportation CSV'
- AR: 'خطأ في تصدير CSV'

---

### 2. Admin Products Page  
**File**: `lib/features/admin/products/app/pages/admin_products_page.dart`

**Line 583**:
```dart
// Current:
TopToast.show(context, 'Erreur lors de l\'exportation CSV', isError: true);

// Should be:
TopToast.show(context, AppLanguage.csvExportError, isError: true);
```

---

### 3. Add Product Page
**File**: `lib/features/admin/products/app/pages/add_product_page.dart`

**Line 108**:
```dart
// Current:
TopToast.show(context, 'Erreur de chargement: $e', isError: true);

// Should be:
// Need to add AppLanguage constant: loadingError
TopToast.show(context, '${AppLanguage.loadingError}: $e', isError: true);
```

**Line 165**:
```dart
// Current:
TopToast.show(context, 'Erreur de chargement du produit: $e', isError: true);

// Should be:
// Need to add AppLanguage constant: productLoadingError  
TopToast.show(context, '${AppLanguage.productLoadingError}: $e', isError: true);
```

---

### 4. Invoice Detail Page
**File**: `lib/features/profile/app/pages/invoice_detail_page.dart`

**Line 62**:
```dart
// Current:
TopToast.show(context, 'Aucun PDF disponible', isError: true);

// Should be:
TopToast.show(context, AppLanguage.noPdfAvailable, isError: true);
```
Note: `AppLanguage.noPdfAvailable` already exists

**Line 72**:
```dart
// Current:
TopToast.show(context, 'Impossible d\'ouvrir le PDF', isError: true);

// Should be:
TopToast.show(context, AppLanguage.pdfDownloadError, isError: true);
```
Note: `AppLanguage.pdfDownloadError` already exists

---

## New AppLanguage Constants Required

The following constants need to be added to `lib/utils/constants/app_language.dart`:

### 1. loadingError
```dart
'loadingError': {
  AppLocale.en: 'Loading error',
  AppLocale.fr: 'Erreur de chargement',
  AppLocale.ar: 'خطأ في التحميل',
},

static String get loadingError => _t('loadingError');
```

### 2. productLoadingError
```dart
'productLoadingError': {
  AppLocale.en: 'Product loading error',
  AppLocale.fr: 'Erreur de chargement du produit',
  AppLocale.ar: 'خطأ في تحميل المنتج',
},

static String get productLoadingError => _t('productLoadingError');
```

---

## Existing Constants to Use

These constants already exist in AppLanguage and can be used immediately:

1. **csvExportError** - Already available
   - EN: 'Error exporting CSV'
   - FR: 'Erreur lors de l\'exportation CSV'
   - AR: 'خطأ في تصدير CSV'

2. **noPdfAvailable** - Already available
   - EN: 'No PDF available'
   - FR: 'Aucun PDF disponible'
   - AR: 'لا يوجد PDF متاح'

3. **pdfDownloadError** - Already available
   - EN: 'Error opening PDF'
   - FR: 'Erreur lors de l\'ouverture du PDF'
   - AR: 'خطأ في فتح PDF'

---

## Benefits

After these changes:
- ✅ All toast messages will be in the user's selected language
- ✅ Consistent error messages across admin and user features
- ✅ Better user experience for Arabic/French/English speakers
- ✅ Easier to maintain and update messages

---

## Implementation Steps

1.  **Add new constants** to `app_language.dart`:
   - `loadingError`
   - `productLoadingError`

2. **Update files** in this order:
   - admin_orders_page.dart (1 change)
   - admin_products_page.dart (1 change)
   - add_product_page.dart (2 changes)
   - invoice_detail_page.dart (2 changes)

3. **Test** each page to verify:
   - Error messages appear in correct language
   - Switching language updates the messages
   - All three languages work (EN, FR, AR)
