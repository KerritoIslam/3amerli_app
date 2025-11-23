import 'package:flutter/foundation.dart';

enum AppLocale { en, fr, ar }

/// Simple in-memory localization helper with reactive updates.
///
/// Usage: set current locale with `AppLanguage.current = AppLocale.fr` and
/// read strings like `AppLanguage.cancel`.
/// Widgets can listen to changes using `AppLanguage.localeNotifier`.
class AppLanguage {
  AppLanguage._();

  static AppLocale _current = AppLocale.fr;

  /// Notifier for reactive language changes - widgets can listen to this
  static final ValueNotifier<AppLocale> localeNotifier =
      ValueNotifier<AppLocale>(_current);

  static AppLocale get current => _current;

  static set current(AppLocale value) {
    if (_current != value) {
      _current = value;
      localeNotifier.value = value;
    }
  }

  static final Map<String, Map<AppLocale, String>> _translations = {
    // Onboarding & Auth
    'welcomeTitle': {
      AppLocale.en: 'Welcome to 3amerli',
      AppLocale.fr: 'Bienvenue chez 3amerli',
      AppLocale.ar: 'مرحبًا بك في عمّرلي',
    },
    'welcomeTo': {
      AppLocale.en: 'Welcome to',
      AppLocale.fr: 'Bienvenue sur',
      AppLocale.ar: 'مرحبًا بك في',
    },
    'welcomeSubtitle': {
      AppLocale.en: 'Order from your favorite stores with ease',
      AppLocale.fr:
          'Commandez depuis vos magasins préférés en toute simplicité',
      AppLocale.ar: 'اطلب من متاجرك المفضلة بكل سهولة',
    },
    'saveTimeMoney': {
      AppLocale.en: 'Save time and money',
      AppLocale.fr: 'Économisez temps et argent',
      AppLocale.ar: 'وفر الوقت والمال',
    },
    'wholesaleBenefits': {
      AppLocale.en:
          'Enjoy competitive prices thanks to wholesale and receive your orders directly to your store',
      AppLocale.fr:
          'Profitez de prix compétitifs grâce à la vente en gros et recevez vos commandes directement dans votre supérette',
      AppLocale.ar:
          'استمتع بأسعار تنافسية بفضل البيع بالجملة واستلم طلباتك مباشرة في متجرك',
    },
    'oneClickOrder': {
      AppLocale.en: 'Order with one click',
      AppLocale.fr: 'Commandez en un click',
      AppLocale.ar: 'اطلب بنقرة واحدة',
    },
    'exploreCatalogDeliveryPayments': {
      AppLocale.en:
          'Explore our catalog, track your deliveries in real-time and pay securely, all from your smartphone',
      AppLocale.fr:
          'Explorez notre catalogue, suivez vos livraisons en temps réel et payez de manière sécurisée, le tout depuis votre smartphone',
      AppLocale.ar:
          'استكشف كتالوجنا، تتبع عمليات التسليم في الوقت الفعلي وادفع بشكل آمن، كل ذلك من هاتفك الذكي',
    },
    'letsGo': {
      AppLocale.en: 'Let\'s go!',
      AppLocale.fr: 'C\'est parti !',
      AppLocale.ar: 'هيا بنا!',
    },
    'skip': {
      AppLocale.en: 'Skip',
      AppLocale.fr: 'Passer',
      AppLocale.ar: 'تخطي',
    },
    'next': {
      AppLocale.en: 'Next',
      AppLocale.fr: 'Suivant',
      AppLocale.ar: 'التالي',
    },
    'phoneNumberTitle': {
      AppLocale.en: 'Enter your phone number',
      AppLocale.fr: 'Entrez votre numéro de téléphone',
      AppLocale.ar: 'أدخل رقم هاتفك',
    },
    'phoneNumberSubtitle': {
      AppLocale.en:
          'Enter your phone number to create your account or sign in.',
      AppLocale.fr:
          'Entrez votre numéro de téléphone pour créer votre compte ou vous connecter.',
      AppLocale.ar: 'أدخل رقم هاتفك لإنشاء حسابك أو تسجيل الدخول.',
    },
    'sendCode': {
      AppLocale.en: 'Send Code',
      AppLocale.fr: 'Envoyer le code',
      AppLocale.ar: 'إرسال الرمز',
    },
    'verifyNumber': {
      AppLocale.en: 'Verify your number',
      AppLocale.fr: 'Vérifiez votre numéro',
      AppLocale.ar: 'تحقق من رقمك',
    },
    'codeSent': {
      AppLocale.en: 'We sent you a code by SMS',
      AppLocale.fr: 'Nous vous avons envoyé un code par SMS',
      AppLocale.ar: 'لقد أرسلنا لك رمزًا عبر الرسائل القصيرة',
    },
    'noCodeReceived': {
      AppLocale.en: 'Didn\'t receive the code?',
      AppLocale.fr: 'Vous n\'avez pas reçu le code ?',
      AppLocale.ar: 'لم تتلق الرمز؟',
    },
    'verifyMyNumber': {
      AppLocale.en: 'Verify my number',
      AppLocale.fr: 'Vérifier mon numéro',
      AppLocale.ar: 'تحقق من رقمي',
    },
    'consentText': {
      AppLocale.en: 'By continuing, you agree to our',
      AppLocale.fr: 'En continuant, vous acceptez nos',
      AppLocale.ar: 'بالمتابعة، فإنك توافق على',
    },
    'consentPrefix': {
      AppLocale.en: 'By continuing, you agree to our',
      AppLocale.fr: 'En continuant, vous acceptez nos',
      AppLocale.ar: 'بالمتابعة، فإنك توافق على',
    },
    'termsOfUse': {
      AppLocale.en: 'Terms of Use',
      AppLocale.fr: 'Conditions d\'utilisation',
      AppLocale.ar: 'شروط الاستخدام',
    },
    'and': {
      AppLocale.en: 'and',
      AppLocale.fr: 'et',
      AppLocale.ar: 'و',
    },
    'privacyPolicy': {
      AppLocale.en: 'Privacy Policy',
      AppLocale.fr: 'Politique de confidentialité',
      AppLocale.ar: 'سياسة الخصوصية',
    },
    'phoneEmptyError': {
      AppLocale.en: 'Please enter your phone number',
      AppLocale.fr: 'Veuillez entrer votre numéro de téléphone',
      AppLocale.ar: 'الرجاء إدخال رقم هاتفك',
    },
    'phoneInvalidError': {
      AppLocale.en: 'Please enter a valid phone number',
      AppLocale.fr: 'Veuillez entrer un numéro de téléphone valide',
      AppLocale.ar: 'الرجاء إدخال رقم هاتف صحيح',
    },

    // Common Actions
    'cancel': {
      AppLocale.en: 'Cancel',
      AppLocale.fr: 'Annuler',
      AppLocale.ar: 'إلغاء',
    },
    'add': {
      AppLocale.en: 'Add',
      AppLocale.fr: 'Ajouter',
      AppLocale.ar: 'إضافة',
    },
    'edit': {
      AppLocale.en: 'Edit',
      AppLocale.fr: 'Modifier',
      AppLocale.ar: 'تعديل',
    },
    'delete': {
      AppLocale.en: 'Delete',
      AppLocale.fr: 'Supprimer',
      AppLocale.ar: 'حذف',
    },
    'save': {
      AppLocale.en: 'Save',
      AppLocale.fr: 'Enregistrer',
      AppLocale.ar: 'حفظ',
    },
    'confirm': {
      AppLocale.en: 'Confirm',
      AppLocale.fr: 'Confirmer',
      AppLocale.ar: 'تأكيد',
    },
    'validate': {
      AppLocale.en: 'Validate',
      AppLocale.fr: 'Valider',
      AppLocale.ar: 'تحقق',
    },
    'apply': {
      AppLocale.en: 'Apply',
      AppLocale.fr: 'Appliquer',
      AppLocale.ar: 'تطبيق',
    },
    'applyFilters': {
      AppLocale.en: 'Apply filters',
      AppLocale.fr: 'Appliquer les filtres',
      AppLocale.ar: 'تطبيق المرشحات',
    },
    // Admin Orders & Users
    'orderDetails': {
      AppLocale.en: 'Order Details',
      AppLocale.fr: 'Détails de la commande',
      AppLocale.ar: 'تفاصيل الطلب',
    },
    'orderedItems': {
      AppLocale.en: 'Ordered Items',
      AppLocale.fr: 'Articles commandés',
      AppLocale.ar: 'العناصر المطلوبة',
    },
    'clientInfo': {
      AppLocale.en: 'Client Information',
      AppLocale.fr: 'Informations du client',
      AppLocale.ar: 'معلومات العميل',
    },
    'storeName': {
      AppLocale.en: 'Store Name',
      AppLocale.fr: 'Nom de la supérette',
      AppLocale.ar: 'اسم المتجر',
    },
    'representativeName': {
      AppLocale.en: 'Representative Name',
      AppLocale.fr: 'Nom et prénom du réprésentant',
      AppLocale.ar: 'اسم الممثل',
    },
    'fullAddress': {
      AppLocale.en: 'Full Address',
      AppLocale.fr: 'Adresse complète',
      AppLocale.ar: 'العنوان الكامل',
    },
    'paymentInfo': {
      AppLocale.en: 'Payment Information',
      AppLocale.fr: 'Informations du paiement',
      AppLocale.ar: 'معلومات الدفع',
    },
    'dateTime': {
      AppLocale.en: 'Date and Time',
      AppLocale.fr: 'Date et heure',
      AppLocale.ar: 'التاريخ والوقت',
    },
    'currentStatus': {
      AppLocale.en: 'Current Status',
      AppLocale.fr: 'Statut actuel',
      AppLocale.ar: 'الحالة الحالية',
    },
    'nextStep': {
      AppLocale.en: 'Next Step',
      AppLocale.fr: 'Étape suivante',
      AppLocale.ar: 'الخطوة التالية',
    },
    'orderNotFound': {
      AppLocale.en: 'Order not found',
      AppLocale.fr: 'Commande non trouvée',
      AppLocale.ar: 'الطلب غير موجود',
    },
    'statusUpdated': {
      AppLocale.en: 'Status updated successfully',
      AppLocale.fr: 'Statut mis à jour avec succès',
      AppLocale.ar: 'تم تحديث الحالة بنجاح',
    },
    'quantityAbbr': {
      AppLocale.en: 'Qty',
      AppLocale.fr: 'Qté',
      AppLocale.ar: 'الكمية',
    },
    'orderNumber': {
      AppLocale.en: 'Order No.',
      AppLocale.fr: 'N° Commande',
      AppLocale.ar: 'رقم الطلب',
    },
    'client': {
      AppLocale.en: 'Client',
      AppLocale.fr: 'Client',
      AppLocale.ar: 'العميل',
    },
    'noOrdersFound': {
      AppLocale.en: 'No orders found',
      AppLocale.fr: 'Aucune commande trouvée',
      AppLocale.ar: 'لم يتم العثور على طلبات',
    },
    'deleteOrders': {
      AppLocale.en: 'Delete Orders',
      AppLocale.fr: 'Supprimer les commandes',
      AppLocale.ar: 'حذف الطلبات',
    },
    'deleteOrdersConfirm': {
      AppLocale.en: 'Are you sure you want to delete',
      AppLocale.fr: 'Êtes-vous sûr de vouloir supprimer',
      AppLocale.ar: 'هل أنت متأكد أنك تريد حذف',
    },
    'exportCSV': {
      AppLocale.en: 'Export CSV',
      AppLocale.fr: 'Exporter CSV',
      AppLocale.ar: 'تصدير CSV',
    },
    'suspended': {
      AppLocale.en: 'Suspended',
      AppLocale.fr: 'Suspendu',
      AppLocale.ar: 'معلق',
    },
    'role': {
      AppLocale.en: 'Role',
      AppLocale.fr: 'Rôle',
      AppLocale.ar: 'الدور',
    },
    'confirmDelete': {
      AppLocale.en: 'Confirm Delete',
      AppLocale.fr: 'Confirmer la suppression',
      AppLocale.ar: 'تأكيد الحذف',
    },
    'confirmDeleteUser': {
      AppLocale.en: 'Are you sure you want to delete this user?',
      AppLocale.fr: 'Voulez-vous vraiment supprimer cet utilisateur ?',
      AppLocale.ar: 'هل أنت متأكد أنك تريد حذف هذا المستخدم؟',
    },
    'confirmDeleteUsers': {
      AppLocale.en: 'Are you sure you want to delete these users?',
      AppLocale.fr: 'Voulez-vous vraiment supprimer ces utilisateurs ?',
      AppLocale.ar: 'هل أنت متأكد أنك تريد حذف هؤلاء المستخدمين؟',
    },
    'deleteSelected': {
      AppLocale.en: 'Delete Selected',
      AppLocale.fr: 'Supprimer la sélection',
      AppLocale.ar: 'حذف المحدد',
    },
    'selectedCount': {
      AppLocale.en: 'selected',
      AppLocale.fr: 'sélectionné(s)',
      AppLocale.ar: 'محدد',
    },
    'openOrderLinkedToNotification': {
      AppLocale.en: 'Open order linked to notification',
      AppLocale.fr: 'Ouvrir la commande liée à la notification',
      AppLocale.ar: 'فتح الطلب المرتبط بالإشعار',
    },
    'reset': {
      AppLocale.en: 'Reset',
      AppLocale.fr: 'Réinitialiser',
      AppLocale.ar: 'إعادة تعيين',
    },
    'close': {
      AppLocale.en: 'Close',
      AppLocale.fr: 'Fermer',
      AppLocale.ar: 'إغلاق',
    },
    'viewAll': {
      AppLocale.en: 'View All',
      AppLocale.fr: 'Voir tout',
      AppLocale.ar: 'عرض الكل',
    },
    'viewDetails': {
      AppLocale.en: 'View Details',
      AppLocale.fr: 'Voir le détail',
      AppLocale.ar: 'عرض التفاصيل',
    },
    'retry': {
      AppLocale.en: 'Retry',
      AppLocale.fr: 'Réessayer',
      AppLocale.ar: 'إعادة المحاولة',
    },
    'loading': {
      AppLocale.en: 'Loading...',
      AppLocale.fr: 'Chargement...',
      AppLocale.ar: 'جارٍ التحميل...',
    },
    'search': {
      AppLocale.en: 'Search',
      AppLocale.fr: 'Rechercher',
      AppLocale.ar: 'بحث',
    },
    'filter': {
      AppLocale.en: 'Filter',
      AppLocale.fr: 'Filtrer',
      AppLocale.ar: 'تصفية',
    },
    'sort': {
      AppLocale.en: 'Sort',
      AppLocale.fr: 'Trier',
      AppLocale.ar: 'فرز',
    },

    // Common Labels
    'all': {
      AppLocale.en: 'All',
      AppLocale.fr: 'Tout',
      AppLocale.ar: 'الكل',
    },
    'product': {
      AppLocale.en: 'Product',
      AppLocale.fr: 'Produit',
      AppLocale.ar: 'منتج',
    },
    'products': {
      AppLocale.en: 'Products',
      AppLocale.fr: 'Produits',
      AppLocale.ar: 'منتجات',
    },
    'order': {
      AppLocale.en: 'Order',
      AppLocale.fr: 'Commande',
      AppLocale.ar: 'طلب',
    },
    'orders': {
      AppLocale.en: 'Orders',
      AppLocale.fr: 'Commandes',
      AppLocale.ar: 'الطلبات',
    },
    'myOrdersNav': {
      AppLocale.en: 'Orders',
      AppLocale.fr: 'Commandes',
      AppLocale.ar: 'الطلبات',
    },
    'user': {
      AppLocale.en: 'User',
      AppLocale.fr: 'Utilisateur',
      AppLocale.ar: 'مستخدم',
    },
    'users': {
      AppLocale.en: 'Users',
      AppLocale.fr: 'Utilisateurs',
      AppLocale.ar: 'مستخدمون',
    },
    'category': {
      AppLocale.en: 'Category',
      AppLocale.fr: 'Catégorie',
      AppLocale.ar: 'فئة',
    },
    'categories': {
      AppLocale.en: 'Categories',
      AppLocale.fr: 'Catégories',
      AppLocale.ar: 'فئات',
    },
    'subcategory': {
      AppLocale.en: 'Subcategory',
      AppLocale.fr: 'Sous-catégorie',
      AppLocale.ar: 'فئة فرعية',
    },
    'subcategories': {
      AppLocale.en: 'Subcategories',
      AppLocale.fr: 'Sous-catégories',
      AppLocale.ar: 'فئات فرعية',
    },
    'brand': {
      AppLocale.en: 'Brand',
      AppLocale.fr: 'Marque',
      AppLocale.ar: 'علامة تجارية',
    },
    'brands': {
      AppLocale.en: 'Brands',
      AppLocale.fr: 'Marques',
      AppLocale.ar: 'علامات تجارية',
    },
    'price': {
      AppLocale.en: 'Price',
      AppLocale.fr: 'Prix',
      AppLocale.ar: 'السعر',
    },
    'stock': {
      AppLocale.en: 'Stock',
      AppLocale.fr: 'Stock',
      AppLocale.ar: 'المخزون',
    },
    'actions': {
      AppLocale.en: 'Actions',
      AppLocale.fr: 'Actions',
      AppLocale.ar: 'إجراءات',
    },
    'mainCategory': {
      AppLocale.en: 'Main category',
      AppLocale.fr: 'Catégorie principale',
      AppLocale.ar: 'الفئة الرئيسية',
    },
    'name': {
      AppLocale.en: 'Name',
      AppLocale.fr: 'Nom',
      AppLocale.ar: 'الاسم',
    },
    'date': {
      AppLocale.en: 'Date',
      AppLocale.fr: 'Date',
      AppLocale.ar: 'التاريخ',
    },
    'status': {
      AppLocale.en: 'Status',
      AppLocale.fr: 'Statut',
      AppLocale.ar: 'الحالة',
    },
    // 'role' removed (duplicate)

    'address': {
      AppLocale.en: 'Address',
      AppLocale.fr: 'Adresse',
      AppLocale.ar: 'العنوان',
    },
    'phone': {
      AppLocale.en: 'Phone',
      AppLocale.fr: 'Téléphone',
      AppLocale.ar: 'الهاتف',
    },
    'email': {
      AppLocale.en: 'Email',
      AppLocale.fr: 'Email',
      AppLocale.ar: 'البريد الإلكتروني',
    },
    'description': {
      AppLocale.en: 'Description',
      AppLocale.fr: 'Description',
      AppLocale.ar: 'الوصف',
    },
    'image': {
      AppLocale.en: 'Image',
      AppLocale.fr: 'Image',
      AppLocale.ar: 'الصورة',
    },
    'quantity': {
      AppLocale.en: 'Quantity',
      AppLocale.fr: 'Quantité',
      AppLocale.ar: 'الكمية',
    },
    'total': {
      AppLocale.en: 'Total',
      AppLocale.fr: 'Total',
      AppLocale.ar: 'المجموع',
    },
    'soldByLabel': {
      AppLocale.en: 'Sold by',
      AppLocale.fr: 'Vendu par',
      AppLocale.ar: 'يباع من طرف',
    },
    'perBatchOf': {
      AppLocale.en: 'Per batch of',
      AppLocale.fr: 'Par lot de',
      AppLocale.ar: 'لكل دفعة من',
    },

    // Status Values
    'cancelled': {
      AppLocale.en: 'Cancelled',
      AppLocale.fr: 'Annulées',
      AppLocale.ar: 'ملغاة',
    },
    'inProgress': {
      AppLocale.en: 'In Progress',
      AppLocale.fr: 'En cours',
      AppLocale.ar: 'قيد التقدم',
    },
    'delivered': {
      AppLocale.en: 'Delivered',
      AppLocale.fr: 'Livrées',
      AppLocale.ar: 'تم التسليم',
    },
    'pending': {
      AppLocale.en: 'Pending',
      AppLocale.fr: 'En attente',
      AppLocale.ar: 'معلق',
    },
    'inStock': {
      AppLocale.en: 'In Stock',
      AppLocale.fr: 'En stock',
      AppLocale.ar: 'متوفر',
    },
    'outOfStock': {
      AppLocale.en: 'Out of Stock',
      AppLocale.fr: 'Rupture',
      AppLocale.ar: 'غير متوفر',
    },

    // Empty States
    'noProductsFound': {
      AppLocale.en: 'No products found',
      AppLocale.fr: 'Aucun produit trouvé',
      AppLocale.ar: 'لم يتم العثور على منتجات',
    },
    // 'noOrdersFound' removed (duplicate)

    'noUsersFound': {
      AppLocale.en: 'No users found',
      AppLocale.fr: 'Aucun utilisateur trouvé',
      AppLocale.ar: 'لم يتم العثور على مستخدمين',
    },
    'noCategoriesFound': {
      AppLocale.en: 'No categories found',
      AppLocale.fr: 'Aucune catégorie trouvée',
      AppLocale.ar: 'لم يتم العثور على فئات',
    },
    'noBrandsFound': {
      AppLocale.en: 'No brands found',
      AppLocale.fr: 'Aucune marque trouvée',
      AppLocale.ar: 'لم يتم العثور على علامات تجارية',
    },
    'noFavoritesFound': {
      AppLocale.en: 'No favorites found',
      AppLocale.fr: 'Aucun favori trouvé',
      AppLocale.ar: 'لم يتم العثور على مفضلات',
    },
    'emptyCart': {
      AppLocale.en: 'Your cart is empty',
      AppLocale.fr: 'Votre panier est vide',
      AppLocale.ar: 'سلتك فارغة',
    },

    // Errors
    'error': {
      AppLocale.en: 'Error',
      AppLocale.fr: 'Erreur',
      AppLocale.ar: 'خطأ',
    },
    'loadingError': {
      AppLocale.en: 'Loading error',
      AppLocale.fr: 'Erreur de chargement',
      AppLocale.ar: 'خطأ في التحميل',
    },
    'networkError': {
      AppLocale.en: 'Network error',
      AppLocale.fr: 'Erreur réseau',
      AppLocale.ar: 'خطأ في الشبكة',
    },
    'unknownError': {
      AppLocale.en: 'Unknown error',
      AppLocale.fr: 'Erreur inconnue',
      AppLocale.ar: 'خطأ غير معروف',
    },

    // Messages
    'pleaseSelectCategory': {
      AppLocale.en: 'Please select a category',
      AppLocale.fr: 'Veuillez sélectionner une catégorie',
      AppLocale.ar: 'يرجى اختيار فئة',
    },
    'pleaseSelectBrand': {
      AppLocale.en: 'Please select a brand',
      AppLocale.fr: 'Veuillez sélectionner une marque',
      AppLocale.ar: 'يرجى اختيار علامة تجارية',
    },
    'defineYourLocation': {
      AppLocale.en: 'Set your location',
      AppLocale.fr: 'Définissez votre localisation',
      AppLocale.ar: 'حدد موقعك',
    },
    'enterAddressHint': {
      AppLocale.en: 'Specify your address to receive your deliveries.',
      AppLocale.fr: 'Précisez votre adresse pour recevoir vos livraisons.',
      AppLocale.ar: 'حدد عنوانك لاستلام طلباتك.',
    },
    // 'confirmDelete' removed (duplicate)

    'deleteSuccess': {
      AppLocale.en: 'Deleted successfully',
      AppLocale.fr: 'Supprimé avec succès',
      AppLocale.ar: 'تم الحذف بنجاح',
    },
    'saveSuccess': {
      AppLocale.en: 'Saved successfully',
      AppLocale.fr: 'Enregistré avec succès',
      AppLocale.ar: 'تم الحفظ بنجاح',
    },
    'updateSuccess': {
      AppLocale.en: 'Updated successfully',
      AppLocale.fr: 'Mis à jour avec succès',
      AppLocale.ar: 'تم التحديث بنجاح',
    },
    'addedToCart': {
      AppLocale.en: 'Added to cart',
      AppLocale.fr: 'Ajouté au panier',
      AppLocale.ar: 'تمت الإضافة إلى السلة',
    },
    'chooseFile': {
      AppLocale.en: 'Choose a file',
      AppLocale.fr: 'Choisir un fichier',
      AppLocale.ar: 'اختر ملفًا',
    },
    'setAsMainImage': {
      AppLocale.en: 'Set as main image',
      AppLocale.fr: 'Définir comme image principale',
      AppLocale.ar: 'تعيين كصورة رئيسية',
    },
    'deleteProduct': {
      AppLocale.en: 'Delete product',
      AppLocale.fr: 'Supprimer le produit',
      AppLocale.ar: 'حذف المنتج',
    },
    'deleteProducts': {
      AppLocale.en: 'Delete products',
      AppLocale.fr: 'Supprimer les produits',
      AppLocale.ar: 'حذف المنتجات',
    },
    'confirmDeletion': {
      AppLocale.en: 'Confirm deletion',
      AppLocale.fr: 'Confirmer la suppression',
      AppLocale.ar: 'تأكيد الحذف',
    },
    'areYouSureDelete': {
      AppLocale.en: 'Are you sure you want to delete this?',
      AppLocale.fr: 'Êtes-vous sûr de vouloir supprimer ceci ?',
      AppLocale.ar: 'هل أنت متأكد أنك تريد حذف هذا؟',
    },
    'openSettings': {
      AppLocale.en: 'Open settings',
      AppLocale.fr: 'Ouvrir les paramètres',
      AppLocale.ar: 'فتح الإعدادات',
    },
    'permissionRequired': {
      AppLocale.en: 'Permission required',
      AppLocale.fr: 'Permission requise',
      AppLocale.ar: 'إذن مطلوب',
    },
    'locationPermissionDenied': {
      AppLocale.en: 'Location permission denied',
      AppLocale.fr: 'Permission de localisation refusée',
      AppLocale.ar: 'تم رفض إذن الموقع',
    },
    'unableToGetLocation': {
      AppLocale.en: 'Unable to get location',
      AppLocale.fr: 'Impossible de récupérer la position',
      AppLocale.ar: 'تعذر الحصول على الموقع',
    },
    'locationPluginUnavailable': {
      AppLocale.en: 'Location plugin unavailable. Please restart the app.',
      AppLocale.fr:
          'Le plugin de localisation n\'est pas disponible. Redémarrez l\'application.',
      AppLocale.ar: 'مكوِّن تحديد الموقع غير متاح. يرجى إعادة تشغيل التطبيق.',
    },
    'gettingLocation': {
      AppLocale.en: 'Getting location...',
      AppLocale.fr: 'Récupération de la position...',
      AppLocale.ar: 'جارٍ الحصول على الموقع...',
    },
    'locationPermissionPermanentlyDenied': {
      AppLocale.en:
          'Location permission is permanently denied. Please enable it in app settings.',
      AppLocale.fr:
          'La permission de localisation est définitivement refusée. Veuillez l\'activer dans les paramètres de l\'application.',
      AppLocale.ar:
          'تم رفض إذن الموقع بشكل دائم. يرجى تفعيله من إعدادات التطبيق.',
    },
    'useCurrentLocation': {
      AppLocale.en: 'Use my current location',
      AppLocale.fr: 'Utiliser ma position actuelle',
      AppLocale.ar: 'استخدام موقعي الحالي',
    },
    'selectDeliveryAddress': {
      AppLocale.en: 'Please select a delivery address',
      AppLocale.fr: 'Veuillez sélectionner une adresse de livraison',
      AppLocale.ar: 'يرجى اختيار عنوان التسليم',
    },
    'backToAddresses': {
      AppLocale.en: 'Back to addresses',
      AppLocale.fr: 'Retour à mes adresses',
      AppLocale.ar: 'العودة إلى العناوين',
    },
    'myAddresses': {
      AppLocale.en: 'My addresses',
      AppLocale.fr: 'Mes adresses',
      AppLocale.ar: 'عناويني',
    },
    'addressCreationFailed': {
      AppLocale.en: 'Failed to create address',
      AppLocale.fr: 'Échec de la création de l\'adresse',
      AppLocale.ar: 'فشل إنشاء العنوان',
    },
    'streetAndNumber': {
      AppLocale.en: 'Street and number *',
      AppLocale.fr: 'Rue et numéro *',
      AppLocale.ar: 'الشارع والرقم *',
    },
    'districtOrCommune': {
      AppLocale.en: 'District / Commune',
      AppLocale.fr: 'Quartier / Commune',
      AppLocale.ar: 'الحي / البلدية',
    },
    'cityLabel': {
      AppLocale.en: 'City',
      AppLocale.fr: 'Ville',
      AppLocale.ar: 'المدينة',
    },
    'fieldRequired': {
      AppLocale.en: 'This field is required',
      AppLocale.fr: 'Ce champ est requis',
      AppLocale.ar: 'هذا الحقل مطلوب',
    },
    'print': {
      AppLocale.en: 'Print',
      AppLocale.fr: 'Imprimer',
      AppLocale.ar: 'طباعة',
    },
    'noPdfAvailable': {
      AppLocale.en: 'No PDF available',
      AppLocale.fr: 'Aucun PDF disponible',
      AppLocale.ar: 'لا يوجد PDF متاح',
    },
    'unableToDownloadPdf': {
      AppLocale.en: 'Unable to download PDF',
      AppLocale.fr: 'Impossible de télécharger le PDF',
      AppLocale.ar: 'تعذر تنزيل PDF',
    },
    'unableToOpenPdf': {
      AppLocale.en: 'Unable to open PDF',
      AppLocale.fr: 'Impossible d\'ouvrir le PDF',
      AppLocale.ar: 'تعذر فتح PDF',
    },
    'unableToOpenPhone': {
      AppLocale.en: 'Unable to open phone dialer',
      AppLocale.fr: 'Impossible d\'ouvrir le composeur téléphonique',
      AppLocale.ar: 'تعذر فتح طلب الهاتف',
    },
    'unableToOpenEmail': {
      AppLocale.en: 'Unable to open email client',
      AppLocale.fr: 'Impossible d\'ouvrir le client mail',
      AppLocale.ar: 'تعذر فتح عميل البريد الإلكتروني',
    },
    'contactUsDirectly': {
      AppLocale.en: 'Contact us directly at:',
      AppLocale.fr: 'Contactez-nous directement au :',
      AppLocale.ar: 'اتصل بنا مباشرة على:',
    },
    'takePhoto': {
      AppLocale.en: 'Take a photo',
      AppLocale.fr: 'Prendre une photo',
      AppLocale.ar: 'التقاط صورة',
    },
    'chooseFromGallery': {
      AppLocale.en: 'Choose from gallery',
      AppLocale.fr: 'Choisir depuis la galerie',
      AppLocale.ar: 'اختر من المعرض',
    },
    'editProfilePhoto': {
      AppLocale.en: 'Edit profile photo',
      AppLocale.fr: 'Modifier la photo de profil',
      AppLocale.ar: 'تعديل صورة الملف الشخصي',
    },
    'profilePhotoUpdated': {
      AppLocale.en: 'Profile photo updated successfully',
      AppLocale.fr: 'Photo de profil mise à jour avec succès',
      AppLocale.ar: 'تم تحديث صورة الملف الشخصي بنجاح',
    },
    'errorUpdatingPhoto': {
      AppLocale.en: 'Error updating photo',
      AppLocale.fr: 'Erreur lors de la mise à jour',
      AppLocale.ar: 'خطأ في تحديث الصورة',
    },
    'editMyInfo': {
      AppLocale.en: 'Edit my information',
      AppLocale.fr: 'Modifier mes informations',
      AppLocale.ar: 'تعديل معلوماتي',
    },
    'editFormNotImplemented': {
      AppLocale.en: 'Edit form (to be implemented)',
      AppLocale.fr: 'Formulaire d\'édition (à implémenter)',
      AppLocale.ar: 'نموذج التعديل (سيتم تنفيذه)',
    },
    'failedToLoadInvoices': {
      AppLocale.en: 'Failed to load invoices',
      AppLocale.fr: 'Échec du chargement des factures',
      AppLocale.ar: 'فشل تحميل الفواتير',
    },
    'openingInvoice': {
      AppLocale.en: 'Opening invoice...',
      AppLocale.fr: 'Ouverture facture...',
      AppLocale.ar: 'جارٍ فتح الفاتورة...',
    },
    'completeYourProfile': {
      AppLocale.en: 'Complete your profile',
      AppLocale.fr: 'Complétez votre profil',
      AppLocale.ar: 'أكمل ملفك الشخصي',
    },
    'completeProfileSubtitle': {
      AppLocale.en:
          'This information helps us personalize your offers and verify your account.',
      AppLocale.fr:
          'Ces informations nous permettent de personnaliser vos offres et de valider votre compte.',
      AppLocale.ar: 'تساعدنا هذه المعلومات على تخصيص عروضك والتحقق من حسابك.',
    },
    'storeNameLabel': {
      AppLocale.en: 'Store name *',
      AppLocale.fr: 'Nom de la supérette *',
      AppLocale.ar: 'اسم المتجر *',
    },
    'representativeNameLabel': {
      AppLocale.en: 'Representative full name',
      AppLocale.fr: 'Nom et prénom du représentant',
      AppLocale.ar: 'الاسم الكامل للمُمثل',
    },
    'validateAndContinue': {
      AppLocale.en: 'Validate and continue',
      AppLocale.fr: 'Valider et continuer',
      AppLocale.ar: 'تحقق واستمر',
    },
    'registrationFailed': {
      AppLocale.en: 'Registration failed',
      AppLocale.fr: 'Échec de l\'enregistrement',
      AppLocale.ar: 'فشل التسجيل',
    },
    'orderNotAvailable': {
      AppLocale.en: 'Order not available',
      AppLocale.fr: 'Commande non disponible',
      AppLocale.ar: 'الطلب غير متاح',
    },
    'loadingProductError': {
      AppLocale.en: 'Error loading product',
      AppLocale.fr: 'Erreur de chargement du produit',
      AppLocale.ar: 'خطأ في تحميل المنتج',
    },
    'addWithPlus': {
      AppLocale.en: '+ Add',
      AppLocale.fr: '+ Ajouter',
      AppLocale.ar: '+ إضافة',
    },
    'deleteProductConfirm': {
      AppLocale.en: 'Are you sure you want to delete this product?',
      AppLocale.fr: 'Êtes-vous sûr de vouloir supprimer ce produit ?',
      AppLocale.ar: 'هل أنت متأكد أنك تريد حذف هذا المنتج؟',
    },
    'deleteProductsConfirm': {
      AppLocale.en: 'Are you sure you want to delete these products?',
      AppLocale.fr: 'Êtes-vous sûr de vouloir supprimer ces produits ?',
      AppLocale.ar: 'هل أنت متأكد أنك تريد حذف هذه المنتجات؟',
    },
    'deleteCategoryConfirm': {
      AppLocale.en: 'Are you sure you want to delete this category?',
      AppLocale.fr: 'Êtes-vous sûr de vouloir supprimer cette catégorie ?',
      AppLocale.ar: 'هل أنت متأكد أنك تريد حذف هذه الفئة؟',
    },
    'deleteSubcategoryConfirm': {
      AppLocale.en: 'Are you sure you want to delete this subcategory?',
      AppLocale.fr: 'Êtes-vous sûr de vouloir supprimer cette sous-catégorie ?',
      AppLocale.ar: 'هل أنت متأكد أنك تريد حذف هذه الفئة الفرعية؟',
    },
    'deleteBrandConfirm': {
      AppLocale.en: 'Do you want to delete "{name}"?',
      AppLocale.fr: 'Voulez-vous supprimer "{name}" ?',
      AppLocale.ar: 'هل تريد حذف "{name}"؟',
    },
    'brandUpdated': {
      AppLocale.en: 'Brand updated',
      AppLocale.fr: 'Marque mise à jour',
      AppLocale.ar: 'تم تحديث العلامة التجارية',
    },
    'brandAdded': {
      AppLocale.en: 'Brand added',
      AppLocale.fr: 'Marque ajoutée',
      AppLocale.ar: 'تمت إضافة العلامة التجارية',
    },
    'brandDeleted': {
      AppLocale.en: 'Brand deleted',
      AppLocale.fr: 'Marque supprimée',
      AppLocale.ar: 'تم حذف العلامة التجارية',
    },
    'deleteError': {
      AppLocale.en: 'Delete error',
      AppLocale.fr: 'Erreur de suppression',
      AppLocale.ar: 'خطأ في الحذف',
    },
    'noDataAvailable': {
      AppLocale.en: 'No data available',
      AppLocale.fr: 'Aucune donnée disponible',
      AppLocale.ar: 'لا توجد بيانات متاحة',
    },
    'selected': {
      AppLocale.en: 'selected',
      AppLocale.fr: 'sélectionné(s)',
      AppLocale.ar: 'محدد',
    },
    'manageCategories': {
      AppLocale.en: 'Manage categories',
      AppLocale.fr: 'Gérer les catégories',
      AppLocale.ar: 'إدارة الفئات',
    },
    'manageBrands': {
      AppLocale.en: 'Manage brands',
      AppLocale.fr: 'Gérer les marques',
      AppLocale.ar: 'إدارة العلامات التجارية',
    },
    'exportProducts': {
      AppLocale.en: 'Export products',
      AppLocale.fr: 'Exporter les produits',
      AppLocale.ar: 'تصدير المنتجات',
    },

    // Support
    'needHelpTitle': {
      AppLocale.en: 'Need Help?',
      AppLocale.fr: 'Besoin d\'aide ?',
      AppLocale.ar: 'هل تحتاج مساعدة؟',
    },
    'contactUsDirectlyAt': {
      AppLocale.en: 'Contact us directly at',
      AppLocale.fr: 'Contactez-nous directement au',
      AppLocale.ar: 'اتصل بنا مباشرة على',
    },
    'or': {
      AppLocale.en: 'or',
      AppLocale.fr: 'ou',
      AppLocale.ar: 'أو',
    },

    // Success Page
    'success': {
      AppLocale.en: 'Success',
      AppLocale.fr: 'Succès',
      AppLocale.ar: 'نجاح',
    },
    'orderLabel': {
      AppLocale.en: 'Order',
      AppLocale.fr: 'Commande',
      AppLocale.ar: 'طلب',
    },
    'amountPaid': {
      AppLocale.en: 'Amount Paid',
      AppLocale.fr: 'Montant payé',
      AppLocale.ar: 'المبلغ المدفوع',
    },
    'followMyOrder': {
      AppLocale.en: 'Follow My Order',
      AppLocale.fr: 'Suivre ma commande',
      AppLocale.ar: 'تتبع طلبي',
    },
    'thankYouPaymentMessage': {
      AppLocale.en: 'Thank you for your payment!',
      AppLocale.fr: 'Merci pour votre paiement !',
      AppLocale.ar: 'شكرا لك على الدفع!',
    },
    'invoiceNotAvailable': {
      AppLocale.en: 'Invoice not available',
      AppLocale.fr: 'Facture non disponible',
      AppLocale.ar: 'الفاتورة غير متوفرة',
    },

    // Cart & Payment
    'pay': {
      AppLocale.en: 'Pay',
      AppLocale.fr: 'Payer',
      AppLocale.ar: 'دفع',
    },
    'payMyOrder': {
      AppLocale.en: 'Pay My Order',
      AppLocale.fr: 'Payer ma commande',
      AppLocale.ar: 'ادفع طلبي',
    },
    'myCart': {
      AppLocale.en: 'My Cart',
      AppLocale.fr: 'Mon Panier',
      AppLocale.ar: 'سلتي',
    },
    'payment': {
      AppLocale.en: 'Payment',
      AppLocale.fr: 'Paiement',
      AppLocale.ar: 'الدفع',
    },
    'paymentMethodTitle': {
      AppLocale.en: 'Payment method',
      AppLocale.fr: 'Mode de paiement',
      AppLocale.ar: 'طريقة الدفع',
    },
    'myProducts': {
      AppLocale.en: 'My Products',
      AppLocale.fr: 'Mes Produits',
      AppLocale.ar: 'منتجاتي',
    },
    'editShort': {
      AppLocale.en: 'Edit',
      AppLocale.fr: 'Modifier',
      AppLocale.ar: 'تعديل',
    },
    'tapToAddDeliveryAddress': {
      AppLocale.en: 'Tap to add a delivery address',
      AppLocale.fr: 'Appuyez pour ajouter une adresse de livraison',
      AppLocale.ar: 'اضغط لإضافة عنوان تسليم',
    },
    'incompleteAddress': {
      AppLocale.en: 'Incomplete address',
      AppLocale.fr: 'Adresse incomplète',
      AppLocale.ar: 'عنوان غير مكتمل',
    },
    'payOnDelivery': {
      AppLocale.en: 'Pay on delivery',
      AppLocale.fr: 'Payez à la livraison',
      AppLocale.ar: 'ادفع عند التسليم',
    },
    'cashPayment': {
      AppLocale.en: 'Cash payment',
      AppLocale.fr: 'Paiement en espèces',
      AppLocale.ar: 'دفع نقدي',
    },
    'onlinePayment': {
      AppLocale.en: 'Online payment',
      AppLocale.fr: 'Paiement en ligne',
      AppLocale.ar: 'دفع عبر الإنترنت',
    },
    'cardPaymentDetails': {
      AppLocale.en: 'Bank card (CIB/EDAHABIA)',
      AppLocale.fr: 'Carte bancaire (CIB/EDAHABIA)',
      AppLocale.ar: 'بطاقة بنكية (CIB/EDAHABIA)',
    },
    'cancelPayment': {
      AppLocale.en: 'Cancel payment',
      AppLocale.fr: 'Annuler le paiement',
      AppLocale.ar: 'إلغاء الدفع',
    },
    'areYouSureCancelPayment': {
      AppLocale.en: 'Are you sure you want to cancel the payment?',
      AppLocale.fr: 'Êtes-vous sûr de vouloir annuler le paiement?',
      AppLocale.ar: 'هل أنت متأكد أنك تريد إلغاء الدفع؟',
    },
    'yesCancel': {
      AppLocale.en: 'Yes, cancel',
      AppLocale.fr: 'Oui, annuler',
      AppLocale.ar: 'نعم، إلغاء',
    },
    'paymentMethod': {
      AppLocale.en: 'Payment Method',
      AppLocale.fr: 'Mode de paiement',
      AppLocale.ar: 'طريقة الدفع',
    },
    'cash': {
      AppLocale.en: 'Cash',
      AppLocale.fr: 'Espèces',
      AppLocale.ar: 'نقدي',
    },
    'card': {
      AppLocale.en: 'Card',
      AppLocale.fr: 'Carte',
      AppLocale.ar: 'بطاقة',
    },
    'deliveryAddress': {
      AppLocale.en: 'Delivery Address',
      AppLocale.fr: 'Adresse de livraison',
      AppLocale.ar: 'عنوان التسليم',
    },
    'addAddress': {
      AppLocale.en: 'Add Address',
      AppLocale.fr: 'Ajouter une adresse',
      AppLocale.ar: 'إضافة عنوان',
    },
    'addNewAddress': {
      AppLocale.en: 'Add New Address',
      AppLocale.fr: 'Ajouter une nouvelle adresse',
      AppLocale.ar: 'إضافة عنوان جديد',
    },
    'validateAddress': {
      AppLocale.en: 'Validate Address',
      AppLocale.fr: 'Valider l\'adresse',
      AppLocale.ar: 'التحقق من العنوان',
    },
    'deliveryFees': {
      AppLocale.en: 'Delivery Fees',
      AppLocale.fr: 'Frais de livraison',
      AppLocale.ar: 'رسوم التوصيل',
    },
    'subtotal': {
      AppLocale.en: 'Subtotal',
      AppLocale.fr: 'Sous-total',
      AppLocale.ar: 'المجموع الفرعي',
    },

    // Success/Failure Pages
    'paymentSuccess': {
      AppLocale.en: 'Payment Successful',
      AppLocale.fr: 'Paiement réussi',
      AppLocale.ar: 'تم الدفع بنجاح',
    },
    'paymentFailed': {
      AppLocale.en: 'Payment Failed',
      AppLocale.fr: 'Échec du paiement',
      AppLocale.ar: 'فشل الدفع',
    },
    'orderPlaced': {
      AppLocale.en: 'Order Placed Successfully',
      AppLocale.fr: 'Commande passée avec succès',
      AppLocale.ar: 'تم تقديم الطلب بنجاح',
    },
    'backToHome': {
      AppLocale.en: 'Back to Home',
      AppLocale.fr: 'Retour à l\'accueil',
      AppLocale.ar: 'العودة إلى الصفحة الرئيسية',
    },
    'downloadOrViewInvoice': {
      AppLocale.en: 'Download or View Invoice',
      AppLocale.fr: 'Télécharger ou visualiser la facture',
      AppLocale.ar: 'تنزيل أو عرض الفاتورة',
    },
    'retryPayment': {
      AppLocale.en: 'Retry Payment',
      AppLocale.fr: 'Réessayer le paiement',
      AppLocale.ar: 'إعادة محاولة الدفع',
    },
    'securePayment': {
      AppLocale.en: 'Secure Payment',
      AppLocale.fr: 'Paiement sécurisé',
      AppLocale.ar: 'دفع آمن',
    },

    // Admin Dashboard
    'dashboard': {
      AppLocale.en: 'Dashboard',
      AppLocale.fr: 'Dashboard',
      AppLocale.ar: 'لوحة القيادة',
    },
    'adminPanel': {
      AppLocale.en: 'Admin Panel',
      AppLocale.fr: 'Panneau d\'administration',
      AppLocale.ar: 'لوحة الإدارة',
    },
    'admin': {
      AppLocale.en: 'Admin',
      AppLocale.fr: 'Admin',
      AppLocale.ar: 'إدارة',
    },
    'statistics': {
      AppLocale.en: 'Statistics',
      AppLocale.fr: 'Statistiques',
      AppLocale.ar: 'إحصائيات',
    },
    'revenue': {
      AppLocale.en: 'Revenue',
      AppLocale.fr: 'Revenus',
      AppLocale.ar: 'الإيرادات',
    },
    'sales': {
      AppLocale.en: 'Sales',
      AppLocale.fr: 'Ventes',
      AppLocale.ar: 'المبيعات',
    },

    // Profile & Settings
    'myOrders': {
      AppLocale.en: 'My Orders',
      AppLocale.fr: 'Mes Commandes',
      AppLocale.ar: 'طلباتي',
    },
    'myAccount': {
      AppLocale.en: 'My Account',
      AppLocale.fr: 'Mon Compte',
      AppLocale.ar: 'حسابي',
    },
    'favorites': {
      AppLocale.en: 'Favorites',
      AppLocale.fr: 'Favoris',
      AppLocale.ar: 'المفضلات',
    },
    'notifications': {
      AppLocale.en: 'Notifications',
      AppLocale.fr: 'Notifications',
      AppLocale.ar: 'الإشعارات',
    },
    'language': {
      AppLocale.en: 'Language',
      AppLocale.fr: 'Langue',
      AppLocale.ar: 'اللغة',
    },
    'selectLanguage': {
      AppLocale.en: 'Select Language',
      AppLocale.fr: 'Choisir la langue',
      AppLocale.ar: 'اختر اللغة',
    },
    'languageUpdated': {
      AppLocale.en: 'Language updated',
      AppLocale.fr: 'Langue mise à jour',
      AppLocale.ar: 'تم تحديث اللغة',
    },
    'logout': {
      AppLocale.en: 'Logout',
      AppLocale.fr: 'Se déconnecter',
      AppLocale.ar: 'تسجيل الخروج',
    },
    'settings': {
      AppLocale.en: 'Settings',
      AppLocale.fr: 'Paramètres',
      AppLocale.ar: 'الإعدادات',
    },
    'theme': {
      AppLocale.en: 'Theme',
      AppLocale.fr: 'Thème',
      AppLocale.ar: 'السمة',
    },
    'darkMode': {
      AppLocale.en: 'Dark Mode',
      AppLocale.fr: 'Mode sombre',
      AppLocale.ar: 'الوضع الداكن',
    },
    'lightMode': {
      AppLocale.en: 'Light Mode',
      AppLocale.fr: 'Mode clair',
      AppLocale.ar: 'الوضع الفاتح',
    },

    // Language Names
    'french': {
      AppLocale.en: 'French',
      AppLocale.fr: 'Français',
      AppLocale.ar: 'الفرنسية',
    },
    'english': {
      AppLocale.en: 'English',
      AppLocale.fr: 'Anglais',
      AppLocale.ar: 'الإنجليزية',
    },
    'arabic': {
      AppLocale.en: 'Arabic',
      AppLocale.fr: 'Arabe',
      AppLocale.ar: 'العربية',
    },

    // Navigation
    'home': {
      AppLocale.en: 'Home',
      AppLocale.fr: 'Accueil',
      AppLocale.ar: 'الرئيسية',
    },
    'cart': {
      AppLocale.en: 'Cart',
      AppLocale.fr: 'Panier',
      AppLocale.ar: 'السلة',
    },
    'profile': {
      AppLocale.en: 'Profile',
      AppLocale.fr: 'Profil',
      AppLocale.ar: 'الملف الشخصي',
    },
    'invoices': {
      AppLocale.en: 'Invoices',
      AppLocale.fr: 'Factures',
      AppLocale.ar: 'الفواتير',
    },
    'supportAndHelp': {
      AppLocale.en: 'Help & Support',
      AppLocale.fr: 'Aide & Support',
      AppLocale.ar: 'المساعدة والدعم',
    },
    'ordersTabAll': {
      AppLocale.en: 'All',
      AppLocale.fr: 'Tout',
      AppLocale.ar: 'الكل',
    },
    'ordersTabInProgress': {
      AppLocale.en: 'In Progress',
      AppLocale.fr: 'En cours',
      AppLocale.ar: 'قيد التنفيذ',
    },
    'ordersTabDelivered': {
      AppLocale.en: 'Delivered',
      AppLocale.fr: 'Livrées',
      AppLocale.ar: 'تم التسليم',
    },
    'ordersTabCanceled': {
      AppLocale.en: 'Cancelled',
      AppLocale.fr: 'Annulées',
      AppLocale.ar: 'ملغاة',
    },
    'ordersTitle': {
      AppLocale.en: 'My Orders',
      AppLocale.fr: 'Mes Commandes',
      AppLocale.ar: 'طلباتي',
    },
    'items': {
      AppLocale.en: 'items',
      AppLocale.fr: 'articles',
      AppLocale.ar: 'عناصر',
    },
    'follow': {
      AppLocale.en: 'Follow',
      AppLocale.fr: 'Suivre',
      AppLocale.ar: 'متابعة',
    },
    'cannotOpenDialer': {
      AppLocale.en: 'Cannot open dialer',
      AppLocale.fr: 'Impossible d\'ouvrir le composeur',
      AppLocale.ar: 'تعذر فتح الهاتف',
    },
    'cannotOpenMailClient': {
      AppLocale.en: 'Cannot open mail client',
      AppLocale.fr: 'Impossible d\'ouvrir l\'application mail',
      AppLocale.ar: 'تعذر فتح البريد',
    },
    'personalInformation': {
      AppLocale.en: 'Personal Information',
      AppLocale.fr: 'Informations personnelles',
      AppLocale.ar: 'المعلومات الشخصية',
    },
    'additional': {
      AppLocale.en: 'Additional',
      AppLocale.fr: 'Supplémentaire',
      AppLocale.ar: 'إضافي',
    },
    'details': {
      AppLocale.en: 'Details',
      AppLocale.fr: 'Détails',
      AppLocale.ar: 'التفاصيل',
    },
    'soldBy': {
      AppLocale.en: 'Package',
      AppLocale.fr: 'Colis',
      AppLocale.ar: 'الحزمة',
    },
    'unknown': {
      AppLocale.en: 'Unknown',
      AppLocale.fr: 'Inconnu',
      AppLocale.ar: 'غير معروف',
    },
    'currency': {
      AppLocale.en: 'DZD',
      AppLocale.fr: 'DZD',
      AppLocale.ar: 'دج',
    },
    'units': {
      AppLocale.en: 'units',
      AppLocale.fr: 'unités',
      AppLocale.ar: 'وحدة',
    },
    'deliveredIn48h': {
      AppLocale.en: 'Delivered in 48h',
      AppLocale.fr: 'Livré en 48h',
      AppLocale.ar: 'التوصيل خلال 48 ساعة',
    },
    'specifications': {
      AppLocale.en: 'Specifications',
      AppLocale.fr: 'Spécifications',
      AppLocale.ar: 'المواصفات',
    },
    'productAddedToCart': {
      AppLocale.en: 'Product added to cart',
      AppLocale.fr: 'Votre produit a bien été ajouté au panier',
      AppLocale.ar: 'تمت إضافة المنتج إلى السلة',
    },
    'removedFromFavorites': {
      AppLocale.en: 'removed from favorites',
      AppLocale.fr: 'retiré des favoris',
      AppLocale.ar: 'تمت الإزالة من المفضلة',
    },
    'addedToFavorites': {
      AppLocale.en: 'added to favorites',
      AppLocale.fr: 'ajouté aux favoris',
      AppLocale.ar: 'تمت الإضافة إلى المفضلة',
    },

    // Dashboard Stats
    'ordersToday': {
      AppLocale.en: 'Orders Today',
      AppLocale.fr: 'Commandes aujourd\'hui',
      AppLocale.ar: 'طلبات اليوم',
    },
    'turnover': {
      AppLocale.en: 'Turnover',
      AppLocale.fr: 'Chiffre d\'affaires',
      AppLocale.ar: 'رقم المعاملات',
    },
    'activeSupermarkets': {
      AppLocale.en: 'Active Supermarkets',
      AppLocale.fr: 'Supérettes actives',
      AppLocale.ar: 'المتاجر النشطة',
    },
    'deliveriesInProgress': {
      AppLocale.en: 'Deliveries in Progress',
      AppLocale.fr: 'Livraisons en cours',
      AppLocale.ar: 'التوصيلات قيد التنفيذ',
    },
    'performance': {
      AppLocale.en: 'Performance',
      AppLocale.fr: 'Performance',
      AppLocale.ar: 'الأداء',
    },
    'salesEvolution': {
      AppLocale.en: 'Sales Evolution',
      AppLocale.fr: 'Évolution des ventes',
      AppLocale.ar: 'تطور المبيعات',
    },
    'salesEvolutionDesc': {
      AppLocale.en: 'Sales evolution over the last months',
      AppLocale.fr: 'Évolution des ventes sur les derniers mois',
      AppLocale.ar: 'تطور المبيعات خلال الأشهر الماضية',
    },
    'topProducts': {
      AppLocale.en: 'Top Products',
      AppLocale.fr: 'Meilleurs produits',
      AppLocale.ar: 'أفضل المنتجات',
    },

    // Months
    'jan': {
      AppLocale.en: 'Jan',
      AppLocale.fr: 'Jan',
      AppLocale.ar: 'يناير',
    },
    'feb': {
      AppLocale.en: 'Feb',
      AppLocale.fr: 'Fév',
      AppLocale.ar: 'فبراير',
    },
    'mar': {
      AppLocale.en: 'Mar',
      AppLocale.fr: 'Mar',
      AppLocale.ar: 'مارس',
    },
    'apr': {
      AppLocale.en: 'Apr',
      AppLocale.fr: 'Avr',
      AppLocale.ar: 'أبريل',
    },
    'may': {
      AppLocale.en: 'May',
      AppLocale.fr: 'Mai',
      AppLocale.ar: 'مايو',
    },
    'jun': {
      AppLocale.en: 'Jun',
      AppLocale.fr: 'Juin',
      AppLocale.ar: 'يونيو',
    },
    'jul': {
      AppLocale.en: 'Jul',
      AppLocale.fr: 'Juil',
      AppLocale.ar: 'يوليو',
    },
    'aug': {
      AppLocale.en: 'Aug',
      AppLocale.fr: 'Août',
      AppLocale.ar: 'أغسطس',
    },
    'sep': {
      AppLocale.en: 'Sep',
      AppLocale.fr: 'Sep',
      AppLocale.ar: 'سبتمبر',
    },
    'oct': {
      AppLocale.en: 'Oct',
      AppLocale.fr: 'Oct',
      AppLocale.ar: 'أكتوبر',
    },
    'nov': {
      AppLocale.en: 'Nov',
      AppLocale.fr: 'Nov',
      AppLocale.ar: 'نوفمبر',
    },
    'dec': {
      AppLocale.en: 'Dec',
      AppLocale.fr: 'Déc',
      AppLocale.ar: 'ديسمبر',
    },
  };

  static String _t(String key) => _translations[key]?[current] ?? key;

  // Onboarding & Auth
  static String get welcomeTitle => _t('welcomeTitle');
  static String get welcomeTo => _t('welcomeTo');
  static String get welcomeSubtitle => _t('welcomeSubtitle');
  static String get saveTimeMoney => _t('saveTimeMoney');
  static String get wholesaleBenefits => _t('wholesaleBenefits');
  static String get oneClickOrder => _t('oneClickOrder');
  static String get exploreCatalogDeliveryPayments =>
      _t('exploreCatalogDeliveryPayments');
  static String get letsGo => _t('letsGo');
  static String get skip => _t('skip');
  static String get next => _t('next');
  static String get phoneNumberTitle => _t('phoneNumberTitle');
  static String get phoneNumberSubtitle => _t('phoneNumberSubtitle');
  static String get sendCode => _t('sendCode');
  static String get verifyNumber => _t('verifyNumber');
  static String get codeSent => _t('codeSent');
  static String get noCodeReceived => _t('noCodeReceived');
  static String get verifyMyNumber => _t('verifyMyNumber');
  static String get consentText => _t('consentText');
  static String get consentPrefix => _t('consentPrefix');
  static String get termsOfUse => _t('termsOfUse');
  static String get and => _t('and');
  static String get privacyPolicy => _t('privacyPolicy');
  static String get phoneEmptyError => _t('phoneEmptyError');
  static String get phoneInvalidError => _t('phoneInvalidError');

  // Common Actions
  static String get cancel => _t('cancel');
  static String get add => _t('add');
  static String get edit => _t('edit');
  static String get delete => _t('delete');
  static String get save => _t('save');
  static String get confirm => _t('confirm');
  static String get validate => _t('validate');
  static String get apply => _t('apply');
  static String get reset => _t('reset');
  static String get close => _t('close');
  static String get viewAll => _t('viewAll');
  static String get viewDetails => _t('viewDetails');
  static String get retry => _t('retry');
  static String get loading => _t('loading');
  static String get search => _t('search');
  static String get filter => _t('filter');
  static String get sort => _t('sort');
  static String get applyFilters => _t('applyFilters');

  // Admin Orders & Users
  static String get orderDetails => _t('orderDetails');
  static String get orderedItems => _t('orderedItems');
  static String get clientInfo => _t('clientInfo');
  static String get storeName => _t('storeName');
  static String get representativeName => _t('representativeName');
  static String get fullAddress => _t('fullAddress');
  static String get paymentInfo => _t('paymentInfo');
  static String get dateTime => _t('dateTime');
  static String get currentStatus => _t('currentStatus');
  static String get nextStep => _t('nextStep');
  static String get orderNotFound => _t('orderNotFound');
  static String get statusUpdated => _t('statusUpdated');
  static String get quantityAbbr => _t('quantityAbbr');
  static String get orderNumber => _t('orderNumber');
  static String get client => _t('client');
  static String get noOrdersFound => _t('noOrdersFound');
  static String get deleteOrders => _t('deleteOrders');
  static String get deleteOrdersConfirm => _t('deleteOrdersConfirm');
  static String get exportCSV => _t('exportCSV');
  static String get suspended => _t('suspended');
  static String get role => _t('role');
  static String get confirmDelete => _t('confirmDelete');
  static String get confirmDeleteUser => _t('confirmDeleteUser');
  static String get confirmDeleteUsers => _t('confirmDeleteUsers');
  static String get deleteSelected => _t('deleteSelected');
  static String get selectedCount => _t('selectedCount');
  static String get openOrderLinkedToNotification =>
      _t('openOrderLinkedToNotification');

  // Common Labels
  static String get all => _t('all');
  static String get product => _t('product');
  static String get products => _t('products');
  static String get order => _t('order');
  static String get orders => _t('orders');
  static String get user => _t('user');
  static String get users => _t('users');
  static String get category => _t('category');
  static String get categories => _t('categories');
  static String get subcategory => _t('subcategory');
  static String get subcategories => _t('subcategories');
  static String get brand => _t('brand');
  static String get brands => _t('brands');
  static String get price => _t('price');
  static String get stock => _t('stock');
  static String get actions => _t('actions');
  static String get mainCategory => _t('mainCategory');
  static String get name => _t('name');
  static String get date => _t('date');
  static String get status => _t('status');
  static String get address => _t('address');
  static String get phone => _t('phone');
  static String get email => _t('email');
  static String get description => _t('description');
  static String get image => _t('image');
  static String get quantity => _t('quantity');
  static String get total => _t('total');
  static String get soldByLabel => _t('soldByLabel');
  static String get perBatchOf => _t('perBatchOf');

  // Status Values
  static String get cancelled => _t('cancelled');
  static String get inProgress => _t('inProgress');
  static String get delivered => _t('delivered');
  static String get pending => _t('pending');
  static String get inStock => _t('inStock');
  static String get outOfStock => _t('outOfStock');

  // Empty States
  static String get noProductsFound => _t('noProductsFound');
  static String get noUsersFound => _t('noUsersFound');
  static String get noCategoriesFound => _t('noCategoriesFound');
  static String get noBrandsFound => _t('noBrandsFound');
  static String get noFavoritesFound => _t('noFavoritesFound');
  static String get emptyCart => _t('emptyCart');

  // Errors
  static String get error => _t('error');
  static String get loadingError => _t('loadingError');
  static String get networkError => _t('networkError');
  static String get unknownError => _t('unknownError');

  // Messages
  static String get pleaseSelectCategory => _t('pleaseSelectCategory');
  static String get pleaseSelectBrand => _t('pleaseSelectBrand');
  static String get defineYourLocation => _t('defineYourLocation');
  static String get enterAddressHint => _t('enterAddressHint');
  static String get deleteSuccess => _t('deleteSuccess');
  static String get saveSuccess => _t('saveSuccess');
  static String get updateSuccess => _t('updateSuccess');
  static String get addedToCart => _t('addedToCart');
  static String get chooseFile => _t('chooseFile');
  static String get setAsMainImage => _t('setAsMainImage');
  static String get deleteProduct => _t('deleteProduct');
  static String get deleteProducts => _t('deleteProducts');
  static String get confirmDeletion => _t('confirmDeletion');
  static String get areYouSureDelete => _t('areYouSureDelete');
  static String get openSettings => _t('openSettings');
  static String get permissionRequired => _t('permissionRequired');
  static String get locationPermissionDenied => _t('locationPermissionDenied');
  static String get unableToGetLocation => _t('unableToGetLocation');
  static String get gettingLocation => _t('gettingLocation');
  static String get locationPluginUnavailable =>
      _t('locationPluginUnavailable');
  static String get ordersToday => _t('ordersToday');
  static String get turnover => _t('turnover');
  static String get activeSupermarkets => _t('activeSupermarkets');
  static String get deliveriesInProgress => _t('deliveriesInProgress');
  static String get performance => _t('performance');
  static String get salesEvolution => _t('salesEvolution');
  static String get salesEvolutionDesc => _t('salesEvolutionDesc');
  static String get topProducts => _t('topProducts');
  static String get admin => _t('admin');

  // Month abbreviations
  static String get jan => _t('jan');
  static String get feb => _t('feb');
  static String get mar => _t('mar');
  static String get apr => _t('apr');
  static String get may => _t('may');
  static String get jun => _t('jun');
  static String get jul => _t('jul');
  static String get aug => _t('aug');
  static String get sep => _t('sep');
  static String get oct => _t('oct');
  static String get nov => _t('nov');
  static String get dec => _t('dec');
  static String get locationPermissionPermanentlyDenied =>
      _t('locationPermissionPermanentlyDenied');
  static String get useCurrentLocation => _t('useCurrentLocation');
  static String get selectDeliveryAddress => _t('selectDeliveryAddress');
  static String get backToAddresses => _t('backToAddresses');
  static String get myAddresses => _t('myAddresses');
  static String get addressCreationFailed => _t('addressCreationFailed');
  static String get streetAndNumber => _t('streetAndNumber');
  static String get districtOrCommune => _t('districtOrCommune');
  static String get cityLabel => _t('cityLabel');
  static String get fieldRequired => _t('fieldRequired');
  static String get print => _t('print');
  static String get noPdfAvailable => _t('noPdfAvailable');
  static String get unableToDownloadPdf => _t('unableToDownloadPdf');
  static String get unableToOpenPdf => _t('unableToOpenPdf');
  static String get unableToOpenPhone => _t('unableToOpenPhone');
  static String get unableToOpenEmail => _t('unableToOpenEmail');
  static String get contactUsDirectly => _t('contactUsDirectly');
  static String get takePhoto => _t('takePhoto');
  static String get chooseFromGallery => _t('chooseFromGallery');
  static String get editProfilePhoto => _t('editProfilePhoto');
  static String get profilePhotoUpdated => _t('profilePhotoUpdated');
  static String get errorUpdatingPhoto => _t('errorUpdatingPhoto');
  static String get editMyInfo => _t('editMyInfo');
  static String get editFormNotImplemented => _t('editFormNotImplemented');
  static String get failedToLoadInvoices => _t('failedToLoadInvoices');
  static String get openingInvoice => _t('openingInvoice');
  static String get completeYourProfile => _t('completeYourProfile');
  static String get completeProfileSubtitle => _t('completeProfileSubtitle');
  static String get storeNameLabel => _t('storeNameLabel');
  static String get representativeNameLabel => _t('representativeNameLabel');
  static String get validateAndContinue => _t('validateAndContinue');
  static String get registrationFailed => _t('registrationFailed');
  static String get orderNotAvailable => _t('orderNotAvailable');
  static String get loadingProductError => _t('loadingProductError');
  static String get addWithPlus => _t('addWithPlus');
  static String get deleteProductConfirm => _t('deleteProductConfirm');
  static String get deleteProductsConfirm => _t('deleteProductsConfirm');
  static String get deleteCategoryConfirm => _t('deleteCategoryConfirm');
  static String get deleteSubcategoryConfirm => _t('deleteSubcategoryConfirm');
  static String deleteBrandConfirm(String name) =>
      _t('deleteBrandConfirm').replaceAll('{name}', name);
  static String get brandUpdated => _t('brandUpdated');
  static String get brandAdded => _t('brandAdded');
  static String get brandDeleted => _t('brandDeleted');
  static String get deleteError => _t('deleteError');
  static String get noDataAvailable => _t('noDataAvailable');
  static String get selected => _t('selected');
  static String get manageCategories => _t('manageCategories');
  static String get manageBrands => _t('manageBrands');
  static String get exportProducts => _t('exportProducts');

  // Cart & Payment
  static String get pay => _t('pay');
  static String get payMyOrder => _t('payMyOrder');
  static String get myCart => _t('myCart');
  static String get payment => _t('payment');
  static String get paymentMethodTitle => _t('paymentMethodTitle');
  static String get myProducts => _t('myProducts');
  static String get editShort => _t('editShort');
  static String get tapToAddDeliveryAddress => _t('tapToAddDeliveryAddress');
  static String get incompleteAddress => _t('incompleteAddress');
  static String get payOnDelivery => _t('payOnDelivery');
  static String get cashPayment => _t('cashPayment');
  static String get onlinePayment => _t('onlinePayment');
  static String get cardPaymentDetails => _t('cardPaymentDetails');
  static String get paymentMethod => _t('paymentMethod');
  static String get cash => _t('cash');
  static String get card => _t('card');
  static String get deliveryAddress => _t('deliveryAddress');
  static String get addAddress => _t('addAddress');
  static String get addNewAddress => _t('addNewAddress');
  static String get validateAddress => _t('validateAddress');
  static String get deliveryFees => _t('deliveryFees');
  static String get subtotal => _t('subtotal');

  // Success/Failure Pages
  static String get paymentSuccess => _t('paymentSuccess');
  static String get paymentFailed => _t('paymentFailed');
  static String get orderPlaced => _t('orderPlaced');
  static String get backToHome => _t('backToHome');
  static String get downloadOrViewInvoice => _t('downloadOrViewInvoice');
  static String get retryPayment => _t('retryPayment');
  static String get securePayment => _t('securePayment');
  static String get cancelPayment => _t('cancelPayment');
  static String get areYouSureCancelPayment => _t('areYouSureCancelPayment');
  static String get yesCancel => _t('yesCancel');

  // Admin Dashboard
  static String get dashboard => _t('dashboard');
  static String get adminPanel => _t('adminPanel');
  static String get statistics => _t('statistics');
  static String get revenue => _t('revenue');
  static String get sales => _t('sales');

  // Profile & Settings
  static String get myOrders => _t('myOrders');
  static String get myAccount => _t('myAccount');
  static String get favorites => _t('favorites');
  static String get notifications => _t('notifications');
  static String get language => _t('language');
  static String get selectLanguage => _t('selectLanguage');
  static String get languageUpdated => _t('languageUpdated');
  static String get logout => _t('logout');
  static String get settings => _t('settings');
  static String get theme => _t('theme');
  static String get darkMode => _t('darkMode');
  static String get lightMode => _t('lightMode');

  // Language Names
  static String get french => _t('french');
  static String get english => _t('english');
  static String get arabic => _t('arabic');

  // Navigation
  static String get home => _t('home');
  static String get cart => _t('cart');
  static String get ordersNav => _t('myOrdersNav');
  static String get profile => _t('profile');

  // Support
  static String get needHelpTitle => _t('needHelpTitle');
  static String get contactUsDirectlyAt => _t('contactUsDirectlyAt');
  static String get or => _t('or');

  // Success Page
  static String get success => _t('success');
  static String get orderLabel => _t('orderLabel');
  static String get amountPaid => _t('amountPaid');
  static String get followMyOrder => _t('followMyOrder');
  static String get thankYouPaymentMessage => _t('thankYouPaymentMessage');
  static String get invoiceNotAvailable => _t('invoiceNotAvailable');
  static String get invoices => _t('invoices');
  static String get supportAndHelp => _t('supportAndHelp');
  static String get ordersTabAll => _t('ordersTabAll');
  static String get ordersTabInProgress => _t('ordersTabInProgress');
  static String get ordersTabDelivered => _t('ordersTabDelivered');
  static String get ordersTabCanceled => _t('ordersTabCanceled');
  static String get ordersTitle => _t('ordersTitle');
  static String get items => _t('items');
  static String get follow => _t('follow');
  static String get cannotOpenDialer => _t('cannotOpenDialer');
  static String get cannotOpenMailClient => _t('cannotOpenMailClient');
  static String get personalInformation => _t('personalInformation');
  static String get additional => _t('additional');
  static String get details => _t('details');
  static String get soldBy => _t('soldBy');
  static String get unknown => _t('unknown');
  static String get currency => _t('currency');
  static String get units => _t('units');
  static String get deliveredIn48h => _t('deliveredIn48h');
  static String get specifications => _t('specifications');
  static String get productAddedToCart => _t('productAddedToCart');
  static String get removedFromFavorites => _t('removedFromFavorites');
  static String get addedToFavorites => _t('addedToFavorites');
}
