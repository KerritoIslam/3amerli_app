# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Core Flutter Commands
- `flutter pub get` - Install dependencies
- `flutter run` - Run the app in development mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter test` - Run all tests
- `flutter analyze` - Run static analysis
- `flutter clean` - Clean build artifacts

### API Testing
- `.\scripts\test_api_endpoints.ps1 -BaseUrl "http://localhost/api/v1" -Token "your_token"` - Test API endpoints with custom base URL and auth token

## Architecture Overview

### Project Structure
This is a Flutter e-commerce application called "3amerli" with a clean architecture pattern using:

- **BLoC** for state management
- **Clean Architecture** with separation of data, domain, and presentation layers
- **Dependency Injection** using GetIt service locator
- **Go Router** for navigation and routing

### Key Architecture Components

#### Feature Organization
Each feature follows the structure:
```
lib/features/[feature]/
├── app/
│   ├── bloc/          # BLoC state management
│   └── pages/         # UI screens
├── data/
│   ├── datasources/   # Remote/local data sources
│   ├── models/        # Data transfer objects
│   └── repositories/  # Repository implementations
└── domain/
    ├── entities/      # Business logic objects
    └── repositories/  # Repository interfaces
```

#### Core Configuration
- `lib/core/config/injection.dart` - Dependency injection setup using GetIt
- `lib/core/config/router.dart` - GoRouter configuration with authentication guards
- `lib/core/dio/api_service.dart` - HTTP client configuration
- `lib/utils/constants/app_constants.dart` - App-wide constants including API base URL

#### State Management
- **AuthBloc** - Authentication state (singleton)
- **CatalogBloc** - Product catalog state (singleton)
- **CartBloc** - Shopping cart state (singleton)
- Various feature-specific BLoCs (factory scoped)

#### Authentication & Routing
- Router uses AuthBloc state to determine navigation
- Admin users are redirected to `/admin`, regular users to `/home`
- Deep linking support for payment success/failure pages
- Custom scheme `amerli://` for deep links

### Key Features
- **Authentication** - Phone number OTP with secure storage
- **Catalog** - Product browsing with filters, categories, and brands
- **Shopping Cart** - Local cart management
- **Admin Panel** - User, product, order, and category management
- **Notifications** - Firebase messaging integration
- **Payments** - Integration with payment gateway and deep linking

### API Configuration
The app uses a REST API with base URL configured in `AppConstants.apiBaseUrl`. Currently pointing to a ngrok endpoint for development.

### Testing Strategy
- Unit tests for BLoCs and business logic
- API testing via PowerShell scripts
- Widget tests for UI components

### Development Notes
- Uses Flutter SDK >=3.3.4
- Supports both user and admin roles
- Implements secure token storage
- Includes comprehensive error handling
- Responsive design with skeleton loading states