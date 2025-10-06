enum AppLocale { en, fr, ar }

/// Simple in-memory localization helper.
///
/// Usage: set current locale with `AppLanguage.current = AppLocale.fr` and
/// read strings like `AppLanguage.logIn`.
class AppLanguage {
  AppLanguage._();

  static AppLocale current = AppLocale.en;

  static final Map<String, Map<AppLocale, String>> _translations = {
    'welcomeTitle': {
      AppLocale.en: 'Bienvenue sur',
      AppLocale.fr: 'Bienvenue sur',
      AppLocale.ar: 'Bienvenue sur',
    },
    'welcomeSubtitle': {
      AppLocale.en:
          'Commandez tous vos produits de supérette en quelques clics, sans vous déplacer et en toute simplicité',
      AppLocale.fr:
          'Commandez tous vos produits de supérette en quelques clics, sans vous déplacer et en toute simplicité',
      AppLocale.ar:
          'Commandez tous vos produits de supérette en quelques clics, sans vous déplacer et en toute simplicité',
    },
    'saveTimeMoney': {
      AppLocale.en: 'Économisez temps et argent',
      AppLocale.fr: 'Économisez temps et argent',
      AppLocale.ar: 'Économisez temps et argent',
    },
    'wholesaleBenefits': {
      AppLocale.en:
          'Profitez de prix compétitifs grâce à la vente en gros et recevez vos commandes directement dans votre supérette',
      AppLocale.fr:
          'Profitez de prix compétitifs grâce à la vente en gros et recevez vos commandes directement dans votre supérette',
      AppLocale.ar:
          'Profitez de prix compétitifs grâce à la vente en gros et recevez vos commandes directement dans votre supérette',
    },
    'skip': {
      AppLocale.en: 'Passer',
      AppLocale.fr: 'Passer',
      AppLocale.ar: 'Passer',
    },
    'next': {
      AppLocale.en: 'Suivant',
      AppLocale.fr: 'Suivant',
      AppLocale.ar: 'Suivant',
    },
    'oneClickOrder': {
      AppLocale.en: 'Commandez en un click',
      AppLocale.fr: 'Commandez en un click',
      AppLocale.ar: 'Commandez en un click',
    },
    'exploreCatalogDeliveryPayments': {
      AppLocale.en:
          'Explorez notre catalogue, suivez vos livraisons en temps réel et payez de manière sécurisée, le tout depuis votre smartphone',
      AppLocale.fr:
          'Explorez notre catalogue, suivez vos livraisons en temps réel et payez de manière sécurisée, le tout depuis votre smartphone',
      AppLocale.ar:
          'Explorez notre catalogue, suivez vos livraisons en temps réel et payez de manière sécurisée, le tout depuis votre smartphone',
    },
    'letsGo': {
      AppLocale.en: 'C\u2019est parti !',
      AppLocale.fr: 'C\u2019est parti !',
      AppLocale.ar: 'C\u2019est parti !',
    },
    'phoneNumberIntro': {
      AppLocale.en:
          'Numéro de téléphone Entrez votre numéro de téléphone pour créer votre compte ou vous connecter.',
      AppLocale.fr:
          'Numéro de téléphone Entrez votre numéro de téléphone pour créer votre compte ou vous connecter.',
      AppLocale.ar:
          'Numéro de téléphone Entrez votre numéro de téléphone pour créer votre compte ou vous connecter.',
    },
    'consentText': {
      AppLocale.en:
          'En continuant, vous acceptez nos conditions d\'utilisation et politique de confidentialité.',
      AppLocale.fr:
          'En continuant, vous acceptez nos conditions d\'utilisation et politique de confidentialité.',
      AppLocale.ar:
          'En continuant, vous acceptez nos conditions d\'utilisation et politique de confidentialité.',
    },
    'sendCode': {
      AppLocale.en: 'Envoyer le code',
      AppLocale.fr: 'Envoyer le code',
      AppLocale.ar: 'Envoyer le code',
    },
    'verifyNumber': {
      AppLocale.en: 'Vérification du numéro',
      AppLocale.fr: 'Vérification du numéro',
      AppLocale.ar: 'Vérification du numéro',
    },
    'codeSent': {
      AppLocale.en: 'Un code à 6 chiffres a été envoyé par SMS à votre numéro.',
      AppLocale.fr: 'Un code à 6 chiffres a été envoyé par SMS à votre numéro.',
      AppLocale.ar: 'Un code à 6 chiffres a été envoyé par SMS à votre numéro.',
    },
    'noCodeReceived': {
      AppLocale.en: 'Vous n\'avez pas recu de code? Renvoyer le code',
      AppLocale.fr: 'Vous n\'avez pas recu de code? Renvoyer le code',
      AppLocale.ar: 'Vous n\'avez pas recu de code? Renvoyer le code',
    },
    'verifyMyNumber': {
      AppLocale.en: 'Vérifier mon numero',
      AppLocale.fr: 'Vérifier mon numero',
      AppLocale.ar: 'Vérifier mon numero',
    },
  };

  static String _t(String key) {
    final map = _translations[key];
    if (map == null) return key;
    return map[current] ?? map[AppLocale.en] ?? key;
  }

  // Getters for new keys
  static String get welcomeTitle => _t('welcomeTitle');
  static String get welcomeSubtitle => _t('welcomeSubtitle');
  static String get saveTimeMoney => _t('saveTimeMoney');
  static String get wholesaleBenefits => _t('wholesaleBenefits');
  static String get skip => _t('skip');
  static String get next => _t('next');
  static String get oneClickOrder => _t('oneClickOrder');
  static String get exploreCatalogDeliveryPayments => _t('exploreCatalogDeliveryPayments');
  static String get letsGo => _t('letsGo');
  static String get phoneNumberIntro => _t('phoneNumberIntro');
  static String get consentText => _t('consentText');
  static String get sendCode => _t('sendCode');
  static String get verifyNumber => _t('verifyNumber');
  static String get codeSent => _t('codeSent');
  static String get noCodeReceived => _t('noCodeReceived');
  static String get verifyMyNumber => _t('verifyMyNumber');
}

/// Backwards compatible misspelling alias used in some notes: AppLaungage
/// This simply forwards to `AppLanguage` so older references like
/// `AppLaungage.logIn` still work.
class AppLaungage {
  AppLaungage._();
  static AppLocale get current => AppLanguage.current;
  static set current(AppLocale v) => AppLanguage.current = v;
  // Forward commonly-used getters to the new AppLanguage API.
  static String get welcomeTitle => AppLanguage.welcomeTitle;
  static String get welcomeSubtitle => AppLanguage.welcomeSubtitle;
  static String get saveTimeMoney => AppLanguage.saveTimeMoney;
  static String get wholesaleBenefits => AppLanguage.wholesaleBenefits;
  static String get skip => AppLanguage.skip;
  static String get next => AppLanguage.next;
  static String get oneClickOrder => AppLanguage.oneClickOrder;
  static String get exploreCatalogDeliveryPayments => AppLanguage.exploreCatalogDeliveryPayments;
  static String get letsGo => AppLanguage.letsGo;
  static String get phoneNumberIntro => AppLanguage.phoneNumberIntro;
  static String get consentText => AppLanguage.consentText;
  static String get sendCode => AppLanguage.sendCode;
  static String get verifyNumber => AppLanguage.verifyNumber;
  static String get codeSent => AppLanguage.codeSent;
  static String get noCodeReceived => AppLanguage.noCodeReceived;
  static String get verifyMyNumber => AppLanguage.verifyMyNumber;
}
