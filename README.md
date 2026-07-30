# DawaFind

## Description
DawaFind is a mobile application built to close the information gap between pharmacies and the public in Bujumbura, Burundi. It provides a real-time directory of medicine availability across registered pharmacies, allowing patients to find where their medicine is in stock before leaving home. For pharmacies, DawaFind functions as a stock management and visibility tool.

## Features
- Search for medicines by name and view which pharmacies currently stock them
- Compare prices and availability across pharmacies
- View pharmacy details: location, opening hours, contact info, and ratings
- Get directions to a chosen pharmacy
- Save favorite pharmacies for quick access
- Track search history
- Pharmacy-side inventory management (add, update, remove stock entries)
- Multilingual onboarding (language preference selection)
- User authentication for both patients and pharmacy staff

## Technologies
- **Flutter**: cross-platform mobile frontend
- **Firebase Authentication**: user sign-up and login
- **Cloud Firestore**: real-time database backend
- **Google Maps API**: location and directions
- **BLoC (Business Logic Component)**: state management
- **Agile methodology**: project management approach

## Installation
1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install)
2. Clone the repository:
```
   git clone https://github.com/SamuzuKofi/DawaFind.git
   cd DawaFind
```
3. Install dependencies:
```
   flutter pub get
```

## Firebase Setup
1. Create a project in the [Firebase Console](https://console.firebase.google.com/)
2. Enable **Authentication** (Email/Password or Phone, as configured) and **Cloud Firestore**
3. Download your platform config files:
   - Android: `google-services.json` → place in `android/app/`
   - iOS: `GoogleService-Info.plist` → place in `ios/Runner/`
4. Add your Google Maps API key:
   - Android: `android/app/src/main/AndroidManifest.xml`
   - iOS: `ios/Runner/AppDelegate.swift`
5. Deploy Firestore Security Rules from `firestore.rules` (if using Firebase CLI):
```
   firebase deploy --only firestore:rules
```

## Running the Project
```
flutter run
```
To run tests and static analysis:
```
flutter test
flutter analyze
```

## Folder Structure
```
lib/
├── main.dart
├── app.dart
├── firebase_options.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_routes.dart
│   │   └── app_strings.dart
│   ├── services/
│   │   └── preferences_service.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── validators.dart
└── features/
    ├── admin/
    │   ├── data/datasources/     admin_remote_datasource.dart
    │   ├── data/repositories/    admin_repository_impl.dart
    │   ├── domain/entities/      pharmacy_approval_entity.dart
    │   ├── domain/repositories/  admin_repository.dart
    │   └── presentation/
    │       ├── bloc/   admin_bloc/event/state.dart
    │       └── screens/ admin_screen.dart
    ├── auth/
    │   ├── data/datasources/     auth_remote_datasource.dart
    │   ├── data/repositories/    auth_repository_impl.dart
    │   ├── domain/entities/      user_entity.dart
    │   ├── domain/repositories/  auth_repository.dart
    │   └── presentation/
    │       ├── bloc/   auth_bloc/event/state.dart
    │       └── screens/ login, signup, splash, onboarding_1/2
    ├── drug_not_found/
    │   └── presentation/screens/ drug_not_found_screen.dart
    ├── home/
    │   ├── data/datasources/     home_remote_datasource.dart
    │   ├── data/repositories/    home_repository_impl.dart
    │   ├── domain/entities/      announcement_entity.dart
    │   ├── domain/repositories/  home_repository.dart
    │   └── presentation/
    │       ├── bloc/   home_bloc/event/state.dart
    │       └── screens/ home_patient, home_pharmacist
    ├── inventory/
    │   ├── data/datasources/     inventory_remote_datasource.dart
    │   ├── data/repositories/    inventory_repository_impl.dart
    │   ├── domain/entities/      inventory_item_entity.dart
    │   ├── domain/repositories/  inventory_repository.dart
    │   └── presentation/
    │       ├── bloc/   inventory_bloc/event/state.dart
    │       └── screens/ inventory_screen.dart
    ├── map_view/
    │   └── presentation/screens/ map_view_screen.dart
    ├── pharmacy_detail/
    │   └── presentation/
    │       ├── bloc/   pharmacy_detail_bloc/event/state.dart
    │       └── screens/ pharmacy_detail_screen.dart
    ├── profile/
    │   └── presentation/
    │       ├── bloc/   profile_bloc/event/state.dart
    │       └── screens/ profile_screen.dart
    ├── saved_pharmacies/
    │   └── presentation/
    │       ├── bloc/   saved_pharmacies_bloc/event/state.dart
    │       └── screens/ saved_pharmacies_screen.dart
    └── search/
        ├── data/datasources/     medicine_remote_datasource.dart
        ├── data/repositories/    medicine_repository_impl.dart
        ├── domain/entities/      medicine_entity.dart
        ├── domain/repositories/  medicine_repository.dart
        └── presentation/
            ├── bloc/   search_bloc/event/state.dart
            └── screens/ medicine_search_screen.dart
```
