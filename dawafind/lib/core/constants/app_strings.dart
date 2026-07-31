class AppStrings {
  AppStrings._();

  // App identity
  static const String appName = 'DawaFind';
  static const String tagline = 'Find your medicine, fast.';
  static const String locationTag = 'Burundi · 2025';

  // Onboarding
  static const String onboarding1Title = 'Stop wasting time at pharmacies';
  static const String onboarding1Subtitle =
      'Check which pharmacies near you have your medicine before you leave home.';
  static const String onboarding2Title = 'Search. Find. Go.';
  static const String onboarding2Subtitle =
      'Search any drug and see real-time availability at pharmacies across your city.';
  static const String next = 'Next';
  static const String getStarted = 'Get Started';
  static const String alreadyHaveAccount = 'I already have an account';

  // Auth
  static const String createAccount = 'Create Account';
  static const String welcomeBack = 'Welcome Back';
  static const String fullName = 'Full Name';
  static const String email = 'Email';
  static const String phoneNumber = 'Phone Number';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  // One label, not one per role: the account determines the role, so the
  // login form never asks which one you are.
  static const String logIn = 'Log In';
  static const String forgotPassword = 'Forgot Password?';
  static const String continueWithGoogle = 'Continue with Google';

  // Money
  // The app covers Bujumbura pharmacies, so prices are Burundian francs
  // (ISO 4217 BIF), written locally as FBu — not Rwandan francs.
  static const String currency = 'FBu';

  // Home
  static const String searchPlaceholder = 'Search drug name...';
  static const String quickSearch = 'Quick Search';
  static const String nearbyPharmacies = 'Nearby Pharmacies';
  static const String viewAll = 'View all';
  static const String openNow = 'Open Now';

  // Drug not found
  static const String medicineNotFound = 'Medicine Not Found';
  static const String searchAlternatives = 'Search Alternatives';

  // Language
  static const String selectLanguage = 'Select Language';
  static const String chooseLanguageSubtitle =
      'Choisissez votre langue - Hitamo ururimi';
  static const String english = 'English';
  static const String french = 'Français';
  static const String kirundi = 'Ikirundi';
} // All user-facing string literals (labels, messages, placeholders)
